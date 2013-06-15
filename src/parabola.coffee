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

  WRAP_CLASS = "CodeMirror-activeline"
  BACK_CLASS = "CodeMirror-activeline-background"

  state = 
    delay: null
    lineWidgets: []
    timeline:
      activeLine: null
      activeFrame: null
    slider:
      value: 0

  clearActiveLine = (cm) ->
    if "activeLine" of cm.state
      cm.removeLineClass cm.state.activeLine, "wrap", WRAP_CLASS
      cm.removeLineClass cm.state.activeLine, "background", BACK_CLASS

    if state.timeline.activeLine
      $(state.timeline.activeLine).removeClass("active")
    if state.timeline.activeFrame
      $(state.timeline.activeFrame).removeClass("active")

  updateActiveLine = (cm, lineNumber, frameNumber) ->
    line = cm.getLineHandle(lineNumber)
    # console.log line
    return if cm.state.activeLine is line
    clearActiveLine cm
    cm.addLineClass line, "wrap", WRAP_CLASS
    cm.addLineClass line, "background", BACK_CLASS
    cm.state.activeLine = line

    state.timeline.activeLine = $($("#timeline table tr")[lineNumber + 1])
    state.timeline.activeLine.addClass("active") if state.timeline.activeLine
    
    # update active frame
    #                                                            plus one for header, plus one for 1-indexed css selector
    state.timeline.activeFrame = $("#timeline table tr:nth-child(#{lineNumber + 1 + 1}) td:nth-child(#{frameNumber + 1}) .cell")
    $(state.timeline.activeFrame).addClass("active") if state.timeline.activeFrame

  updateTimelineMarker = (cm, lineNumber, frameNumber) ->
    xpos = 0
    scrollTo = 0
    if state.timeline.activeFrame
      try
        relativeX = $("#timeline").offset().left - $(state.timeline.activeFrame).offset().left
        scrollTo = if relativeX == 0 then 0 else Math.max(relativeX * -1, 0)
        $("#timeline").scrollLeft(scrollTo)

        xpos = $("#timeline").scrollLeft() + $(state.timeline.activeFrame).position().left + 6
      catch e
        # console.log(e)

      marker = $("#tlmark")
      height = $('#timeline table tbody').height()

      rowHeight = 23 # todo read this dynamically - this is for the header row
      marker.css({"top": "-#{height}px", "left": "#{xpos}px", "height": height - rowHeight}) # todo

  editor = CodeMirror $("#editor")[0], {
    value: parabola
    mode:  "javascript"
    viewportMargin: Infinity
    tabMode: "spaces"
    }

  editor.on "change", () ->
    clearTimeout(state.delay)
    state.delay = setTimeout(calculateIterations, 300)

  onSliderChange = (event, ui) ->
    $( "#amount" ).text( "step #{ui.value}" ) 
    state.slider.value = ui.value
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
    updateActiveLine editor, info.lineNumber - 1, info.frameNumber
    updateTimelineMarker editor, info.lineNumber - 1, info.frameNumber

  # When given an array of messages, add CodeMirror lineWidgets to each line
  onMessages = (messages) ->
    firstMessage = messages[0]?.message
    if firstMessage
      _.map messages, (message) ->
        line = editor.getLineHandle(message.lineNumber - 1)
        widgetHtml = $("<div class='line-messages'>" + message.message + "</div>")
        widget = editor.addLineWidget(line, widgetHtml[0])
        state.lineWidgets.push(widget)

  # Generate the HTML view of the timeline data structure
  generateTimelineTable = (timeline) ->
    console.log("generateTimelineTable")
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

    # build a table where the number of rows is
    #   rows: timeline.maxLines
    #   columns: number of elements in 
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
    tableString += "<div id='tlmark'></div>"
    tdiv.html(tableString)

  onTimeline = (timeline) ->
    generateTimelineTable(timeline)

  updatePreview = () ->
    # clear the lineWidgets (e.g. the text description)
    _.map state.lineWidgets, (widget) -> widget.clear()

    try
      window.choc.scrub editor.getValue(), state.slider.value, 
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
          if (state.slider.value > max)
            state.slider.value = max
            slider.slider('value', max)

    window.choc.scrub editor.getValue(), inf, 
      onTimeline: onTimeline
      beforeEach: beforeScrub
      afterEach: afterScrub
      afterAll: afterAll
      locals: { pad: pad }
    updatePreview()

  # first time 
  calculateIterations(true)

