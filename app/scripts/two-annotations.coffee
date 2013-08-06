$(document).ready () ->
  choc = window.choc
  readable = choc.readable

  override = (target, originalName, newfn) ->
    originalFn = target[originalName]
    target[originalName] = (args...) ->
      me = this
      newfn(me, originalFn, args...)

  # Two returns a Two.Polygon for each of shapes. makeLine, makeRectangle,
  # etc. are just convenience functions.  Here we override the toString method
  # on each of these so that when the object is called as readable it has a
  # sensible name other than [object Object]. This is separate from method
  # annotation which tells us how to describe the method call (vs. the object
  # returned)
  overrideToString = (target, originalName, newString) ->
    override target, originalName, (me, originalFn, args...) ->
      ret = originalFn.apply(me, args)
      ret.toString = () -> newString
      ret

  overrides = 
    makeLine: "this line"
    makeRectangle: "this rectangle"
    makeCircle: "this circle"
    makeEllipse: "this ellipse"
    makeCurve: "this curve"
    makePolygon: "this polygon"
    makeGroup: "this group"

  overrideToString(Two.prototype, method, str) for method, str of overrides


  # doesn't quite work yet
  Two.Polygon.prototype.__choc_annotations = 
    linewidth: (args) ->
      "im a line width"

  # Two.prototype.__choc_annotations = 
  #   makeLine: (args) ->
  #    [x1, y1, x2, y2] = readable.readableArgs(args) # TODO pull into the library
  #    "draw a line from (#{x1},#{y1}) to (#{x2},#{y2})"

  strVar = (v) -> "<span class='choc-variable'>#{v}</span>"

  choc.annotate Two.prototype.makeLine, (args) ->
    [x1, y1, x2, y2] = _.map args, (arg) -> strVar(arg)
    "draw a line from (#{x1},#{y1}) to (#{x2},#{y2})"

