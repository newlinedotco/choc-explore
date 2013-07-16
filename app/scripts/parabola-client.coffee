$(document).ready () ->

  parabola = """
    var shift = 0;
    while (shift <= 200) {
      pad.makeLine(shift, 0, 200, shift);
      shift += 14;
    }
  """

  pad = new Two({
    width: 200
    height: 200
    type: Two.Types.canvas
    })
    .appendTo(document.getElementById('targetcanvas'))

  pad.makeLine.__choc_annotation = (args) ->
    "make a line"

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

