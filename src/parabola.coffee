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

  slider = $("#slider").slider {
    slide: (event, ui) -> $( "#amount" ).val( ui.value )
    }

  sourceRewrite = () ->
    options = 
      comment: true
      format:
        quotes: "double"
        indent:
          style: "  "

    try
      code = editor.getValue()
      syntax = window.esprima.parse(code, raw: true, tokens: true, range: true, comment: true)
      syntax = window.escodegen.attachComments(syntax, syntax.comments, syntax.tokens)
      code = window.escodegen.generate(syntax, options)
      editor.setValue code
      $("#messages").text("")
    catch e
      console.log(e)
      $("#messages").text(e.toString())

  updatePreview = () ->
    drawCode = boilerplate(editor.getValue())
    try
      `eval(drawCode)`
      $("#messages").text("")
    catch e
      console.log(e)
      $("#messages").text(e.toString())

  setTimeout(updatePreview, 300)

  console.log("free bird")

