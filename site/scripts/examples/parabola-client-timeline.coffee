$(document).ready () ->
  choc = window.choc

  parabola = """
    var shift = 0;
    while (shift <= 200) {
      var line = pad.makeLine(shift, 0, 200, shift);
      if(shift % 3) {
        line.linewidth = 2;
        line.stroke = "#333";
      }
      shift += 14;
    }
  """ #"

  pad = new Two({
    width: 200
    height: 200
    type: Two.Types.canvas
    })
    .appendTo(document.getElementById('parabola-timeline-canvas'))

  # enable retina
  if window.devicePixelRatio == 2
    canvas = pad.renderer.domElement
    canvas.setAttribute('width', canvas.width*2)
    canvas.setAttribute('height', canvas.height*2)
    pad.renderer.ctx.scale(2, 2)

  editor = new choc.Editor({
    $: $
    id: "#choc-editor-for-parabola-with-timeline"
    timeline: true
    code: parabola
    beforeScrub: () -> pad.clear()
    afterScrub: () ->  pad.update()
    locals: { pad: pad }
    })
  
  editor.start()

