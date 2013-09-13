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

  editor = new window.choc.Editor({
    $: $
    code: parabola
    beforeScrub: () -> pad.clear()
    afterScrub: () ->  pad.update()
    locals: { pad: pad }
    })

  editor.start()

