$(document).ready () ->
  parabola = """
    var shift = 0;
    while (shift <= 200) {
      pad.makeLine(shift, 0, 200, shift);
      shift += 14;
    }
  """
  
  parabola2 = """
    var shift = 0;
    while (shift <= 200) {
      pad.makeLine(shift, 0, 200, shift);
      if(shift % 7 == 0) {
        pad.makeCircle(200 - 5, shift, 5);
      }
      shift += 3;
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
    editor:
      activeLine: null
    timeline:
      activeLine: null
      activeFrame: null
    slider:
      value: 0

  clearActiveLine = (cm) ->
    # if "activeLine" of cm.state
      # cm.removeLineClass cm.state.activeLine, "wrap", WRAP_CLASS
      # cm.removeLineClass cm.state.activeLine, "background", BACK_CLASS
    if state.editor.activeLine
      state.editor.activeLine.removeClass(WRAP_CLASS)
    if state.timeline.activeLine
      state.timeline.activeLine.removeClass("active")
    if state.timeline.activeFrame
      state.timeline.activeFrame.removeClass("active")

  updateActiveLine = (cm, lineNumber, frameNumber) ->
    # line = cm.getLineHandle(lineNumber)
    line = $($(".CodeMirror-lines pre")[lineNumber])
    return if cm.state.activeLine is line
    clearActiveLine cm
    line.addClass(WRAP_CLASS) if line
    # cm.addLineClass line, "wrap", WRAP_CLASS
    # cm.addLineClass line, "background", BACK_CLASS
    #cm.state.activeLine = line
    state.editor.activeLine = line

    state.timeline.activeLine = $($("#timeline table tr")[lineNumber + 1])
    state.timeline.activeLine.addClass("active") if state.timeline.activeLine
    
    # update active frame
    #                                                            plus one for header, plus one for 1-indexed css selector
    # state.timeline.activeFrame = $("#timeline table tr:nth-child(#{lineNumber + 1 + 1}) td:nth-child(#{frameNumber + 1}) .cell")
    # splitting this up into three 'queries' is a lot faster than one giant query (in my profiling in Chrome)
    activeRow   = $("#timeline table tr")[lineNumber + 1]
    activeTd    = $(activeRow).find("td")[frameNumber]
    activeFrame = $(activeTd).find(".cell")
    state.timeline.activeFrame = activeFrame
    state.timeline.activeFrame.addClass("active") if state.timeline.activeFrame

  updateTimelineScroll = () ->
    scrollTo = 0
    if state.timeline.activeFrame
      try
        # relativeX = $("#timeline").offset().left - $(state.timeline.activeFrame).offset().left
        # scrollTo = if relativeX == 0 then 0 else Math.max(relativeX * -1, 0)
        # $("#timeline").scrollLeft(scrollTo)
      catch e
        # console.log(e)

  updateTimelineMarker = () ->
    xpos = 0
    if state.timeline.activeFrame
      try
        xpos = $("#timeline").scrollLeft() + $(state.timeline.activeFrame).position().left + 7
      catch e
        # console.log(e)

      marker = $("#tlmark")
      height = $('#timeline table tbody').height()

      rowHeight = 23 # todo read this dynamically - this is for the header row
      marker.css({"top": "-#{height}px", "left": "#{xpos}px", "height": height - rowHeight}) # todo

  editor = CodeMirror $("#editor")[0], {
    value: parabola2
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
  onScrub = (info,opts={}) ->
    updateActiveLine editor, info.lineNumber - 1, info.frameNumber
    # updateTimelineMarker()
    unless opts.noScroll
      updateTimelineScroll()

  # When given an array of messages, add CodeMirror lineWidgets to each line
  onMessages = (messages) ->
    firstMessage = messages[0]?.message
    # if firstMessage
    #   _.map messages, (message) ->
    #     line = editor.getLineHandle(message.lineNumber - 1)
    #     widgetHtml = $("<div class='line-messages'>" + message.message + "</div>")
    #     widget = editor.addLineWidget(line, widgetHtml[0])
    #     state.lineWidgets.push(widget)

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

        if timeline.stepMap[column][row]
          info = timeline.stepMap[column][row]
          display = "&#8226;"
          tableString += "<td><div class='cell content-cell' data-frame-number='#{info.frameNumber}' data-line-number='#{info.lineNumber}'>#{display}</div></td>\n"
        else
          value = ""
          tableString += "<td><div class='cell'>#{value}</div></td>\n"
        column += 1

      tableString += "</tr>\n"
      row += 1

    tableString += "</table>\n"
    tableString += "<div id='tlmark'></div>"
    tdiv.html(tableString)
    
    for cell in $("#timeline .content-cell")
      ((cell) -> 
        $(cell).mouseover () ->
          # TODO - this doesn't work very well
          cell = $(cell)
          frameNumber = cell.data('frame-number')
          info = {lineNumber: cell.data('line-number'), frameNumber: frameNumber}
          # console.log(info)
          # onScrub(info, {noScroll: true})
          # state.slider.value = frameNumber + 1
          # slider.slider('value', frameNumber + 1)
          # updatePreview()
      )(cell)
    

  onTimeline = (timeline) ->
    generateTimelineTable(timeline)

  updatePreview = () ->
    # clear the lineWidgets (e.g. the text description)

    # _.map state.lineWidgets, (widget) -> widget.clear()

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

    # if first
      # updateTimelineScroll() 
      # updateTimelineMarker() 


  # first time 
  calculateIterations(true)

