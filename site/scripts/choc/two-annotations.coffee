$(document).ready () ->
  choc = window.choc
  readable = choc.readable

  settings = {
    cellWidth: 16
    cellHeight: 16
  }

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
      ret._choc_timeline = () -> "&#8226;"
      ret.noFill()
      ret

  overrides = 
    makeLine: "the line"
    makeRectangle: "the rectangle"
    makeCircle: "the circle"
    makeEllipse: "the ellipse"
    makeCurve: "the curve"
    makePolygon: "the polygon"
    makeGroup: "the group"

  overrideToString(Two.prototype, method, str) for method, str of overrides

  strVar = (v) -> "<span class='choc-variable'>#{v}</span>"

  Two.Polygon.prototype.__choc_annotations = 
    linewidth: (args) -> # doesn't work quite yet because we don't have readable assignment
      "im a line width"

    scale: (args) ->
      [scale] = args
      inline = if scale > 1.0
        "scale bigger by #{strVar(scale)}"
      else
        "scale smaller by #{strVar(scale)}"
      {
        inline: inline
        timeline: (elem) ->
          elem.html(scale)
          elem.removeClass('circle')
      }
      

    fill: (args) ->
      [fill] = args
      {
        inline: "set the fill to <div class='line-swatch' style='background-color: #{fill};'>&nbsp</div>"
        timeline: (elem) ->
          swatch = $("<div></div>").addClass("line-swatch timeline-swatch").css("background-color", fill)
          elem.append(swatch)
          elem.removeClass('circle')
      }

    rotation: (args) ->
      [rot] = args
      {
        inline: "set the rotation to #{strVar(rot)}"
        timeline: (elem) ->
          two = new Two({
            width: settings.cellWidth
            height: settings.cellHeight
            type: Two.Types.canvas
            }).appendTo(elem[0])
          elem.removeClass('circle')
         
          circle = two.makeCircle(0, 0, 6)
          line = two.makeLine(0, 0, -8, 0)
          
          group = two.makeGroup(circle, line)
          group.translation.set(two.width / 2, two.height / 2)
          group.rotation = rot

          two.update()
      }


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
    "draw an ellipse at (#{x},#{y}) with a #{radius} radius"

  choc.annotate Two.prototype.makeCurve, (args) ->
    "draw a curve"

  choc.annotate Two.prototype.makePolygon, (args) ->
    open = args.pop()
    numberOfSides = args.length / 2
    polygonNames = 
      3: "triangle"
      4: "quadrilateral"
      5: "pentagon"
      6: "hexagon"
      7: "heptagon"
      8: "octagon"
      9: "enneagon"
      10: "decagon"
    polygonName = if polygonNames.hasOwnProperty(numberOfSides) 
                    polygonNames[numberOfSides] 
                  else "polygon"

    {
      inline: "draw a #{polygonName}"
      timeline: (elem) ->
        elem.removeClass('circle')

        two = new Two({
          width: settings.cellWidth
          height: settings.cellHeight
          type: Two.Types.canvas
          }).appendTo(elem[0])

        # TODO - the idea here is to create a 'thumbnail' version of the polygon
        maxGiven = _.max(args)
        maxAllowed = _.max([settings.cellWidth, settings.cellHeight])
        scale = maxAllowed / maxGiven
        scaledArgs = _.map(args, ((v) -> v * scale))
        poly = two.makePolygon.apply(two, scaledArgs.concat([open]))

        poly.translation.set(two.width / 2, two.height / 2)
        two.update()

    }

  # Two.prototype.__choc_annotations =
  #   scale: (args) ->
  #     [x1, y1, x2, y2] = readable.readableArgs(args) # TODO pull into the library
  #     "draw a line from (#{x1},#{y1}) to (#{x2},#{y2})"
