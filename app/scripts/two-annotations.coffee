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

  strVar = (v) -> "<span class='choc-variable'>#{v}</span>"

  Two.Polygon.prototype.__choc_annotations = 

    # doesn't work quite yet
    linewidth: (args) ->
      "im a line width"

    scale: (args) ->
      [scale] = args
      if scale > 1.0
        "scale bigger by #{strVar(scale)}"
      else
        "scale smaller by #{strVar(scale)}"

    fill: (args) ->
      [fill] = args
      "set the fill to <div style='width: 17px; height; 17px; background-color: #{fill}; border: 1px solid rgba(68, 67, 67, 0.68); display: inline-block; top: -1px; position: relative;'>&nbsp</div>"


    # TODO - the args that are passed in here aren't usable
    rotation: (args) ->
      [rot] = args
      "set the rotation to #{strVar(rot)}"

  choc.annotate Two.prototype.makeLine, (args) ->
    [x1, y1, x2, y2] = _.map args, (arg) -> strVar(arg)
    "draw a line from (#{x1},#{y1}) to (#{x2},#{y2})"

  choc.annotate Two.prototype.makeRectangle, (args) ->
    [x, y, width, height] = _.map args, (arg) -> strVar(arg)
    "draw a rectangle at (#{x},#{y}) #{width} wide and #{height} high"

  choc.annotate Two.prototype.makeCircle, (args) ->
    [x, y, radius] = _.map args, (arg) -> strVar(arg)
    "draw a circle at (#{x},#{y}) with a radius of #{radius}"

  choc.annotate Two.prototype.makeEllipse, (args) ->
    [x, y, radius] = _.map args, (arg) -> strVar(arg)
    "draw an ellipse at (#{x},#{y}) #{width} wide and #{height} high"

  choc.annotate Two.prototype.makeCurve, (args) ->
    "draw a curve"

  choc.annotate Two.prototype.makePolygon, (args) ->
    "draw a polygon"

  # Two.prototype.__choc_annotations =
  #   scale: (args) ->
  #     [x1, y1, x2, y2] = readable.readableArgs(args) # TODO pull into the library
  #     "draw a line from (#{x1},#{y1}) to (#{x2},#{y2})"
