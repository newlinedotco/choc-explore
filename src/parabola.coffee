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

  timelineState = {}

  clearActiveLine = (cm) ->
    if "activeLine" of cm.state
      cm.removeLineClass cm.state.activeLine, "wrap", WRAP_CLASS
      cm.removeLineClass cm.state.activeLine, "background", BACK_CLASS
    if "activeLine" of timelineState  
      $(timelineState.activeLine).removeClass("active")
    if "activeFrame" of timelineState  
      $(timelineState.activeFrame).removeClass("active")

  updateActiveLine = (cm, lineNumber, frameNumber) ->
    line = cm.getLineHandle(lineNumber)
    # console.log line
    return if cm.state.activeLine is line
    clearActiveLine cm
    cm.addLineClass line, "wrap", WRAP_CLASS
    cm.addLineClass line, "background", BACK_CLASS
    cm.state.activeLine = line
    timelineState.activeLine = $($("#timeline table tr")[lineNumber + 1])
    if timelineState.activeLine
      timelineState.activeLine.addClass("active")
    
    # update active frame
    #                                                            plus one for header, plus one for 1-indexed css selector
    timelineState.activeFrame = $("#timeline table tr:nth-child(#{lineNumber + 1 + 1}) td:nth-child(#{frameNumber + 1}) .cell")
    if timelineState.activeFrame
      $(timelineState.activeFrame).addClass("active")

  updateTimelineMarker = (cm, lineNumber, frameNumber) ->
    marker = $("#tlmark")
    xpos = 0
    if timelineState.activeFrame
      xpos = $(timelineState.activeFrame).position()?.left + 6
    marker.css({"top": "30px", "left": "#{xpos}px", "height": $('#editor').height() - 8}) # todo
    

  editor = CodeMirror $("#editor")[0], {
    value: parabola
    mode:  "javascript"
    viewportMargin: Infinity
    tabMode: "spaces"
    }

  lineWidgets = []

  editor.on "change", () ->
    clearTimeout(delay)
    # delay = setTimeout(updatePreview, 300)

    delay = setTimeout(calculateIterations, 300)

  sliderValue = 0

  onSliderChange = (event, ui) ->
    $( "#amount" ).text( "step #{ui.value}" ) 
    sliderValue = ui.value
    updatePreview()

  slider = $("#slider").slider {
    min: 0
    max: 50
    change: onSliderChange
    slide: onSliderChange
    }

  beforeScrub = () -> pad.clear()
  afterScrub  = () -> pad.update()
  onScrub = (info) ->
    # editor.setCursor info.lineNumber - 1, 0
    # clearActiveLine editor
    updateActiveLine editor, info.lineNumber - 1, info.frameNumber
    updateTimelineMarker editor, info.lineNumber - 1, info.frameNumber
    # console.log(info)

  onMessages = (messages) ->
    firstMessage = messages[0]?.message
    if firstMessage
      # console.log(firstMessage)
      _.map messages, (message) ->
        line = editor.getLineHandle(message.lineNumber - 1)
        widgetHtml = $("<div class='line-messages'>" + message.message + "</div>")
        widget = editor.addLineWidget(line, widgetHtml[0])
        lineWidgets.push(widget)

  onTimeline = (timeline) ->
    tdiv = $("#timeline")
    tableString = "<table>\n"
    
    # header
    tableString += "<tr>\n"
    for column in [0..(timeline.steps.length-1)] by 1
      value = ""
      if (column % 10) == 0
        value = column
      tableString += "<th><div class='cell'>#{value}</div></th>\n"
    tableString += "</tr>\n"

    row  = 0
    while row < timeline.maxLines + 1
      tableString += "<tr>\n"
      column = 0
      while column < timeline.steps.length
        idx = row * column
        value = if timeline.stepMap[column][row] then "&#8226;" else ""
        tableString += "<td><div class='cell'>#{value}</div></td>\n"
        column += 1

      tableString += "</tr>\n"
      row += 1

    tableString += "</table>\n"

    # build a table where the number of rows is
    #   rows: timeline.maxLines
    #   columns: number of elements in 
    # <table>
    #   <tr>
    #     <td>
    #       x
    #     </td>
    #   </tr>
    # </table> 
    tdiv.html(tableString)
    console.log(timeline)

  updatePreview = () ->

    # ew. clear the lineWidgets
    _.map lineWidgets, (widget) ->
      # console.log(widget)
      widget.clear()

    try

      window.choc.scrub editor.getValue(), sliderValue, 
        onFrame: onScrub
        beforeEach: beforeScrub
        afterEach: afterScrub
        onMessages: onMessages
        locals: { pad: pad }
      $("#messages").text("")
    catch e
      console.log(e)
      console.log(e.stack)
      $("#messages").text(e.toString())

  # setTimeout(updatePreview, 300)

  calculateIterations = (first=false) ->
    inf = 1000

    afterAll = \ 
      if first 
        (info) ->
          count = info.frameCount
          slider.slider('option', 'max', count)
          slider.slider('value', count)
      else
        (info) ->
          count = info.frameCount
          slider.slider('option', 'max', count)
          max = slider.slider('option', 'max')
          if (sliderValue > max)
            sliderValue = max
            slider.slider('value', max)
            # $( "#amount" ).text( sliderValue ) 
            #console.log(sliderValue)

    window.choc.scrub editor.getValue(), inf, 
      onTimeline: onTimeline
      beforeEach: beforeScrub
      afterEach: afterScrub
      afterAll: afterAll
      locals: { pad: pad }
    updatePreview()

  # first time 
  calculateIterations(true)

