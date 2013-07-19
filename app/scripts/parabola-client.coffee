$(document).ready () ->
  choc = window.choc

  parabola = """
    var shift = 0;
    while (shift <= 200) {
      pad.makeLine(shift, 0, 200, shift);
      shift += 14;
    }
  """

  # parabola = """
  calling_functions = """
  function add(a, b) {
    var c = 3;
    return a + b;
  }

  var shift = 0;
  while (shift <= 200) {
    var x = add(1, shift) + add(1, 2);
    shift += 14; // increment
  }
  """

  pad = new Two({
    width: 200
    height: 200
    type: Two.Types.canvas
    })
    .appendTo(document.getElementById('targetcanvas'))

  pad.makeLine.__choc_annotation = (args) ->
    [x1, y1, x2, y2] = _.map args, (arg) -> choc.readable.generateReadableExpression(arg)
    "'draw a line from (' + #{x1} + ',' + #{y1} + ') to (' + #{x2} + ',' + #{y2} + ')'"

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

