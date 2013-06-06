$(document).ready () ->
  parabola = """
    var shift = 0;
    while (shift <= 200) {
      pad.makeLine(shift, 0, 200, shift);
      shift += 14;
    }
  """

  boilerplate = (drawCode) -> """
    two = pad;

    #{drawCode}

    pad.update();
  """

  pad = new Two({
    width: 200
    height: 200
    type: Two.Types.canvas
    })
    .appendTo(document.getElementById('targetcanvas'))

  delay = null
  editor = CodeMirror $("#editor")[0], {
    value: parabola
    mode:  "javascript"
    viewportMargin: Infinity
    tabMode: "spaces"
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
      console.log(ui.value)
      sliderValue = ui.value
      updatePreview()
    }

  updatePreview = () ->
    scrubNotify = (info) ->
        console.log(info)

    try
      # `eval(drawCode)`
      window.choc.scrub editor.getValue(), sliderValue, notify: scrubNotify, wrapper: boilerplate, scope: this
      $("#messages").text("")
    catch e
      console.log(e)
      console.log(e.stack)
      $("#messages").text(e.toString())

  setTimeout(updatePreview, 300)

  console.log("free bird")

