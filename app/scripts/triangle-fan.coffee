$(document).ready () ->
  choc = window.choc

  parabola = """
    var i = 0;
    while (i <= 20) {
      var scaleFactor = 1 + (20 - i)/20;
      var triangle = pad.makePolygon(0, 0, 200, -20, 195, 40, false);
      triangle.fill("rgb(" + i * 30 + ", " + i * 18 + ", 0)");
      triangle.scale(scaleFactor);
      triangle.rotation(i * 0.07);
      triangle.translation.set(-20, 40);
      i += 1;
    }
  """

  pad = new Two({
    width: 200
    height: 200
    type: Two.Types.canvas
    })
    .appendTo(document.getElementById('targetcanvas'))

  # pad.makeLine.__choc_annotation = (args) ->
  #   [x1, y1, x2, y2] = _.map args, (arg) -> choc.readable.generateReadableExpressionPlus(arg)
  #   "draw a line from (#{x1},#{y1}) to (#{x2},#{y2})"

  # is there a way to set it on prototypes of things?
  # that would be better, e.g. if we set the stroke of a line - what is that object?
  # e.g. lets set a private setting on the prototype of objects. this way we can read from that object what the language should be
 
  editor = new window.choc.Editor({
    $: $
    code: parabola
    beforeScrub: () -> pad.clear()
    afterScrub: () ->  pad.update()
    locals: { pad: pad }
    })

  editor.start()

