###
Choc
###

express = require("express")
routes = require("./routes")
user = require("./routes/user")
http = require("http")
path = require("path")
assets = require("connect-assets")
_ = require("underscore")
{puts,inspect} = require("util")
coffee = require("coffee-script")
moment = require("moment")

app = express()
app.configure ->
  app.set "port", process.env.PORT or 5003
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.locals.pretty = true
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.cookieParser()
  # app.use express.session({secret: "as23d"})
  app.use express.cookieSession({secret: "gA*nus8*"})
  app.use express.methodOverride()
  # app.use assets({src: path.join(__dirname, "assets"), build: true})
  # app.use assets({src: "assets", build: true})
  app.use assets()
  app.use express.static(path.join(__dirname, "public"))
  app.use app.router

  # error handler
  app.use (err, req, res, next) ->
    res.send 500, { error: err, msg: "#{err.message}\n#{err.stack}" }

app.get "/", (req, res) ->

  res.render('index', {
    title: 'Umbrella'
    thunderRequest: req.session?['thunderRequest']
    thunderContext: req.session?['thunderContext']
  })

# curl -d '{"hello":"world"}' http://127.0.0.1:4000/test/post --header "Accept: application/json" --header "Content-Type: application/json"
app.post "/test/post", (req, res) ->
  puts inspect req.body
  res.json {err: null, data: req.body}

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
