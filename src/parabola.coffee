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

  delay = null

  WRAP_CLASS = "CodeMirror-activeline"
  BACK_CLASS = "CodeMirror-activeline-background"

  clearActiveLine = (cm) ->
    if "activeLine" of cm.state
      cm.removeLineClass cm.state.activeLine, "wrap", WRAP_CLASS
      cm.removeLineClass cm.state.activeLine, "background", BACK_CLASS

  updateActiveLine = (cm, lineNumber) ->
    line = cm.getLineHandle(lineNumber)
    console.log line
    return if cm.state.activeLine is line
    clearActiveLine cm
    cm.addLineClass line, "wrap", WRAP_CLASS
    cm.addLineClass line, "background", BACK_CLASS
    cm.state.activeLine = line

  # CodeMirror.defineOption "styleActiveLine", false, (cm, val, old) ->
  #   prev = old and old isnt CodeMirror.Init
  #   if val and not prev
  #     updateActiveLine cm
  #     cm.on "cursorActivity", updateActiveLine
  #   else if not val and prev
  #     cm.off "cursorActivity", updateActiveLine
  #     clearActiveLine cm
  #     delete cm.state.activeLine

  editor = CodeMirror $("#editor")[0], {
    value: parabola
    mode:  "javascript"
    viewportMargin: Infinity
    tabMode: "spaces"
    # styleActiveLine: true
    }
  editor.on "change", () ->
    clearTimeout(delay)
    delay = setTimeout(updatePreview, 300)

  sliderValue = 0

  slider = $("#slider").slider {
    min: 0
    max: 50
    slide: (event, ui) -> 
      $( "#amount" ).text( ui.value ) 
      sliderValue = ui.value
      updatePreview()
    }

  beforeScrub = () -> pad.clear()
  afterScrub  = () -> pad.update()
  onScrub = (info) ->
    # editor.setCursor info.lineNumber - 1, 0
    # clearActiveLine editor
    updateActiveLine editor, info.lineNumber - 1
    # console.log(info)

  updatePreview = () ->
    try
      window.choc.scrub editor.getValue(), sliderValue, notify: onScrub, beforeEach: beforeScrub, afterEach: afterScrub, locals: { pad: pad }
      $("#messages").text("")
    catch e
      console.log(e)
      console.log(e.stack)
      $("#messages").text(e.toString())

  setTimeout(updatePreview, 300)

