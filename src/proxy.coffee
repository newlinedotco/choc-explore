#
# WARNING!!!
# This file is a sketch of an idea and not actual code that is supposed to be
# used by anyone. Its mostly ripped from replay and hacked from there. This needs
# rewritten with tests etc. before it should be used by anyone
#

# A proxy is a function that receives two arguments, a request object and a callback.
#
# If it can generate a respone, it calls callback with null and the response object.  Otherwise, either calls callback
# with no arguments, or with an error to stop the processing chain.
#
# The request consists of:
# url     - URL object
# method  - Request method (lower case)
# headers - Headers object (names are lower case)
# body    - Request body, an array of body part/encoding pairs
#
# The response consists of:
# version   - HTTP version
# status    - Status code
# headers   - Headers object (names are lower case)
# body      - Array of body parts
# trailers  - Trailers object (names are lower case)
#
# This file defines ProxyRequest, which acts as an HTTP ClientRequest that captures the request and passes it to the
# proxy chain, and ProxyResponse, which acts as an HTTP ClientResponse, playing back a response it received from the
# proxy.
#
# No actual proxies defined here.


assert            = require("assert")
{ EventEmitter }  = require("events")
HTTP              = require("http")
Stream            = require("stream")
URL               = require("url")
DNS           = require("dns")
HTTP          = require("http")
HTTPS         = require("https")
{puts,inspect} = require("util")

# HTTP client request that captures the request and sends it down the processing chain.
class ProxyRequest extends HTTP.ClientRequest
  constructor: (options = {}, @replay, @proxy)->
    @method = (options.method || "GET").toUpperCase()
    [host, port] = (options.host || options.hostname).split(":")
    protocol = options.protocol || "http:"
    port = options.port || port || (if protocol == "https:" then 443 else 80)
    @url = URL.parse("#{protocol}//#{host || "localhost"}:#{port}#{options.path || "/"}")
    @headers = {}
    if options.headers
      for n,v of options.headers
        @headers[n.toLowerCase()] = v

  setHeader: (name, value)->
    assert !@ended, "Already called end"
    assert !@body, "Already wrote body parts"
    @headers[name.toLowerCase()] = value

  getHeader: (name)->
    return @headers[name.toLowerCase()]

  removeHeader: (name)->
    assert !@ended, "Already called end"
    assert !@body, "Already wrote body parts"
    delete @headers[name.toLowerCase()]

  setTimeout: (timeout, callback)->
    @timeout = [timeout, callback]
    return

  setNoDelay: (nodelay = true)->
    @nodelay = [nodelay]
    return

  setSocketKeepAlive: (enable = false, initial)->
    @keepAlive = [enable, initial]
    return

  write: (chunk, encoding)->

    assert !@ended, "Already called end"
    @body ||= []
    @body.push [chunk, encoding]
    return

  end: (data, encoding)->
    assert !@ended, "Already called end"
    if data
      @write data, encoding
    @ended = true

    @proxy this, (error, captured)=>
      # We're not asynchronous, but clients expect us to callback later on
      process.nextTick =>
        if error
          @emit "error", error
        else if captured
          response = new ProxyResponse(captured)
          @emit "response", response
          response.resume()
        else
          error = new Error("#{@method} #{URL.format(@url)} refused: not recording and no network access")
          error.code = "ECONNREFUSED"
          error.errno = "ECONNREFUSED"
          @emit "error", error
    return

  abort: ->


clone = (object)->
  result = {}
  for x, y of object
    result[x] = y
  return result


# HTTP client response that plays back a captured response.
class ProxyResponse extends Stream
  constructor: (captured)->
    @httpVersion = captured.version || "1.1"
    @statusCode  = captured.status || 200
    @headers     = clone(captured.headers)
    @trailers    = clone(captured.trailers)
    @_body       = captured.body.slice(0)
    @readable    = true
    # Not a documented property, but request seems to use this to look for HTTP parsing errors
    @connection  = new EventEmitter()

  pause: ->
    @_paused = true

  resume: ->
    @_paused = false
    process.nextTick =>
      return if @_paused || !@_body
      part = @_body.shift()
      if part
        if @_encoding
          chunk = new Buffer(part).toString(@_encoding)
        else
          chunk = part
        @emit "data", chunk
        @resume()
      else
        @_body = null
        @readable = false
        @_done = true
        @emit "end"

  setEncoding: (@_encoding)->

  @notFound: (url)->
    return new ProxyResponse(status: 404, body: ["No recorded request/response that matches #{URL.format(url)}"])

# Capture original HTTP request. PassThrough proxy uses that.
httpRequest  = HTTP.request
httpsRequest = HTTPS.request


passThrough = (request, callback)->
  options =
    protocol: request.url.protocol
    hostname: request.url.hostname
    port:     request.url.port
    path:     request.url.path
    method:   request.method
    headers:  request.headers

  if request.url.protocol == "https:"
    http = httpsRequest(options)
  else
    http = httpRequest(options)
  http.on "error", (error)->
    callback error
  http.on "response", (response)->
    captured =
      version: response.httpVersion
      status:  response.statusCode
      headers: response.headers
      body:    []
    response.on "data", (chunk)->
      captured.body.push chunk
    response.on "end", ->
      captured.trailers = response.trailers
      callback null, captured
  if request.body
    for part in request.body
      http.write part[0], part[1]
  http.end()


writeHeaders = (headers, only = null)->
  acc = ""
  for name, value of headers
    continue if only && !match(name, only)
    if Array.isArray(value)
      for item in value
        acc += "#{name}: #{item}\n"
    else
      acc += "#{name}: #{value}\n"
  acc

requestToString = (request) ->
  acc = ""
  acc += "#{request.method.toUpperCase()} #{request.url.path || "/"}\n"
  acc += writeHeaders request.headers
  acc += "\n"
  if request.body
    request.body.map(([chunk, encoding]) -> acc += chunk)
    acc += "\n\n"
  acc

responseToString = (response) ->
  acc = ""
  acc += "#{response.status || 200} HTTP/#{response.version || "1.1"}\n"
  acc += writeHeaders response.headers
  acc += "\n"
  for part in response.body
   acc += part
  acc

logRequest = (request, callback) ->
  puts "Replay: Requesting #{request.method} #{URL.format(request.url)}"
  puts requestToString(request)
  callback()

proxy = (proxyCallback) ->
  # todo wrap in a function
  passThroughProxy = (request, callback) ->
      passThrough request, (error, response) ->
        proxyCallback requestToString(request), responseToString(response), () ->
          callback error, response

  # Route HTTP requests to our little helper.
  HTTP.request = (options, callback)->
    # WebSocket request: pass through to Node.js library
    if options && options.headers && options.headers["Upgrade"] == "websocket"
      return httpRequest(options, callback)
    # Proxy request
    request = new ProxyRequest(options, null, passThroughProxy)
    if callback
      request.once "response", (response)->
        callback response
    return request

  # Route HTTPS requests
  HTTPS.request = (options, callback)->
    options.protocol = "https:"
    return HTTP.request(options, callback)

module.exports = proxy
