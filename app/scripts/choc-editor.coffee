class ChocEditor
  WRAP_CLASS = "CodeMirror-activeline"

  constructor: (options) ->
    defaults =
      maxIterations: 1000
      maxAnimationFrames: 100

    @options = _.extend(defaults, options)
    @$ = options.$
    @state = 
      delay: null
      lineWidgets: []
      editor:
        activeLine: null
      timeline:
        activeLine: null
        activeFrame: null
      slider:
        value: 0
    @setupEditor()

  setupEditor: () ->
    @interactiveValues = {
      onChange: (v) =>
        clearTimeout(@state.delay)
        @state.delay = setTimeout(
          (() => 
            @calculateIterations()), 
          1)
    }

    @codemirror = CodeMirror @$("#editor")[0], {
      value: @options.code
      mode:  "javascript"
      viewportMargin: Infinity
      tabMode: "spaces"
      interactiveNumbers: @interactiveValues
      }

    @codemirror.on "change", () =>
      clearTimeout(@state.delay)
      @state.delay = setTimeout((() => @calculateIterations()), 500)

    onSliderChange = (event, ui) =>
      if event.hasOwnProperty("originalEvent") # e.g. triggered by a user interaction, not programmatically below
        @$( "#amount" ).text( "step #{ui.value}" ) 
        @state.slider.value = ui.value
        @updatePreview()

    @slider = @$("#slider").slider {
      min: 0
      max: 50
      change: onSliderChange
      slide: onSliderChange
      }

  beforeScrub: () ->
    @options.beforeScrub()
  
  afterScrub: () ->
    @options.afterScrub()

  clearActiveLine: () ->
    if @state.editor.activeLine
      @state.editor.activeLine.removeClass(WRAP_CLASS)
    if @state.timeline.activeLine
      @state.timeline.activeLine.removeClass("active")
    if @state.timeline.activeFrame
      @state.timeline.activeFrame.removeClass("active")

  updateActiveLine: (cm, lineNumber, frameNumber) ->
    line = @$(@$(".CodeMirror-lines pre")[lineNumber])
    return if cm.state.activeLine is line
    @clearActiveLine()
    line.addClass(WRAP_CLASS) if line
    @state.editor.activeLine = line

    @state.timeline.activeLine = @$(@$("#timeline table tr")[lineNumber + 1])
    @state.timeline.activeLine.addClass("active") if @state.timeline.activeLine
    
    # update active frame
    # splitting this up into three 'queries' is a lot faster than one giant query (in my profiling in Chrome)
    activeRow   = @$("#timeline table tr")[lineNumber + 1]
    activeTd    = @$(activeRow).find("td")[frameNumber]
    activeFrame = @$(activeTd).find(".cell")
    @state.timeline.activeFrame = activeFrame
    @state.timeline.activeFrame.addClass("active") if @state.timeline.activeFrame
    @updateTimelineMarker(activeFrame)

  updateTimelineMarker: (activeFrame) ->
    # TODO figure out the positioning below
    if activeFrame?.position()?
      # $("#tlmark").show()
      # $("#tlmark").height($("#tlmark").parent().height())
      # $("#tlmark").css('top', '0')
      # parentOffset = @$("#tlmark").parent().offset()
      # console.log parentOffset
      # if parentOffset?
      #   # console.log("updateTimelineMarker")
      #   # console.log(parentOffset)
      #   # console.log(activeFrame.offset().left)
      #   relX = activeFrame.position().left - parentOffset.left
      #   console.log(relX)
      #   $("#tlmark").css('left', relX)
      relX = activeFrame.position().left
      @$("#timeline").scrollLeft(relX)


  onScrub: (info,opts={}) ->
    # console.log "onScrub"
    @updateActiveLine @codemirror, info.lineNumber - 1, info.frameNumber
    # updateTimelineMarker()
    # unless opts.noScroll
    #   updateTimelineScroll()

  # When given an array of messages, add CodeMirror lineWidgets to each line
  onMessages: (messages) ->
    firstMessage = messages[0]?.message
    if firstMessage
      _.map messages, (messageInfo) =>
        messageString = ""

        # to make the annotations API cleaner, we allow either a string to be
        # returned or an object with the keys 'message' or 'timeline'
        if _.isObject(messageInfo.message)
          messageString = messageInfo.message.inline
        else
          messageString = messageInfo.message

        line = @codemirror.getLineHandle(messageInfo.lineNumber - 1)
        widgetHtml = $("<div class='line-messages'>" + messageString + "</div>")
        widget = @codemirror.addLineWidget(line, widgetHtml[0])
        @state.lineWidgets.push(widget)

  # Generate the HTML view of the timeline data structure
  # TODO: this is a bit ugly
  generateTimelineTable: (timeline) ->
    tdiv = @$("#timeline")
    execLine = @$("#executionLine")

    table = $('<table></table>')

    # tableString = "<table>\n"

    # onFinish = []
    
    # header
    headerRow = $("<tr></tr>")

    # tableString += "<tr>\n"
    for column in [0..(timeline.steps.length-1)] by 1
      value = ""
      if (column % 10) == 0
        value = column
      headerRow.append("<th><div class='cell'>#{value}</div></th>")
    table.append(headerRow)

    # build a table where the number of rows is
    #   rows: timeline.maxLines
    #   columns: number of elements in 
    rowidx  = 0
    while rowidx < timeline.maxLines + 1
      row = $('<tr class="timeline-row"></tr>')
      #tableString += "<tr>\n"
      column = 0
      while column < timeline.steps.length
        idx = rowidx * column

        if timeline.stepMap[column][rowidx]
          info = timeline.stepMap[column][rowidx]
          # console.log(info)

          message = info.messages?[0]

          display = "&#8226;"
          frameId = "data-frame-#{info.frameNumber}"
          cell = $("<td></td>")
          innerCell = $("<div></div>")
            .addClass("cell content-cell")
            .attr("id", frameId)
            .attr("data-frame-number", info.frameNumber)
            .attr("data-line-number", info.lineNumber)
          cell.append(innerCell)

          if message?.message?.timeline?
            timelineCreator = message.message.timeline
            if _.isFunction(timelineCreator)
              # display = timelineCreator("#" + frameId) # the table hasn't been created yet
              timelineCreator(innerCell)

          else if message?.timeline? 
            display = message.timeline
            if display.hasOwnProperty("_choc_timeline")
              display = display._choc_timeline()
            innerCell.html(display)
          else
            innerCell.html(display)
         
          row.append(cell)
        else
          value = ""
          cell = $("<td><div class='cell'>#{value}</div></td>")
          row.append(cell)
        column += 1
      rowidx += 1
      table.append(row)

    # tableString += "<div id='tlmark'>&nbsp;</div>"
    # tdiv.html(tableString)
    tdiv.html(table)

    # console.log("setup the table")
    #onf() for onf in onFinish
    
    slider = @slider
    updatePreview = @updatePreview
    self = @
    updateSlider = (frameNumber) ->
      self.$( "#amount" ).text( "step #{frameNumber}" ) 
      self.state.slider.value = frameNumber
      # console.log self.state.slider.value
      updatePreview.apply(self)
    for cell in @$("#timeline .content-cell")
      ((cell) -> 
        $(cell).on 'mouseover', () ->
          cell = $(cell)
          frameNumber = cell.data('frame-number')
          info = {lineNumber: cell.data('line-number'), frameNumber: frameNumber}
          updateSlider info.frameNumber + 1
      )(cell)

  onTimeline: (timeline) ->
    @generateTimelineTable(timeline)

  updatePreview: () ->
    # clear the lineWidgets (e.g. the text description)
    _.map @state.lineWidgets, (widget) -> widget.clear()

    try
      code = @codemirror.getValue()

      window.choc.scrub code, @state.slider.value, 
        onFrame:    (args...) => @onScrub.apply(@, args)
        beforeEach: (args...) => @beforeScrub.apply(@, args)
        afterEach:  (args...) => @afterScrub.apply(@, args)
        onMessages: (args...) => @onMessages.apply(@, args)
        locals: @options.locals
      @$("#messages").text("")
    catch e
      console.log(e)
      console.log(e.stack)
      @$("#messages").text(e.toString())

  calculateIterations: (first=false) ->
    afterAll = () -> 
    if first
      afterAll = (info) =>
        count = info.frameCount
        @slider.slider('option', 'max', count)
        @slider.slider('value', count)
        # @options.afterCalculatingIterations() if @options.afterCalculatingIterations?
    else
      afterAll = (info) =>
        count = info.frameCount
        @slider.slider('option', 'max', count)
        max = @slider.slider('option', 'max')
        if (@state.slider.value > max)
          @state.slider.value = max
          @slider.slider('value', max)
          @slider.slider('step', count)

    console.log("regular calculate iterations")
    window.choc.scrub @codemirror.getValue(), @options.maxIterations, 
      onTimeline: (args...) => @onTimeline.apply(@, args)
      beforeEach: (args...) => @beforeScrub.apply(@, args)
      afterEach:  (args...) => @afterScrub.apply(@, args)
      afterFrame:  (args...) => @afterFrame.apply(@, args)
      afterAll: afterAll
      locals: @options.locals

    # @updatePreview() # TODO - bring this back?

    # if first
    #   updateTimelineScroll() 
    #   updateTimelineMarker() 

  start: () ->
    @calculateIterations(true)

root = exports ? this
root.choc.Editor = ChocEditor
