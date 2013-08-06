$(document).ready () ->
  choc = window.choc
  readable = choc.readable

  override = (target, originalName, newfn) ->
    originalFn = target[originalName]
    target[originalName] = (args...) ->
      me = this
      newfn(me, originalFn, args...)

  override Two.prototype, "makeLine", (me, originalFn, args...) ->
    line = originalFn.apply(me, args)
    line.toString = () -> "this line"
    line

  Two.Polygon.prototype.__choc_annotations = 
    linewidth: (args) ->
      "im a line width"

  Two.prototype.__choc_annotations = 
    makeLine: (args) ->
     [x1, y1, x2, y2] = readable.readableArgs(args) # TODO pull into the library
     "draw a line from (#{x1},#{y1}) to (#{x2},#{y2})"

  # choc.annotate Two.prototype.makeLine, (args) ->
  #   [x1, y1, x2, y2] = args
  #   "draw a line from (#{x1},#{y1}) to (#{x2},#{y2})"

