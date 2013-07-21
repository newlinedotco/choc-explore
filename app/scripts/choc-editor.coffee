class ChocEditor
  WRAP_CLASS = "CodeMirror-activeline"

  constructor: (options) ->
    defaults =
      maxIterations: 1000

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

    @codemirror = CodeMirror @$("#editor")[0], {
      value: @options.code
      mode:  "javascript"
      viewportMargin: Infinity
      tabMode: "spaces"
      }

    @codemirror.on "change", () =>
      clearTimeout(@state.delay)
      @state.delay = setTimeout((() => @calculateIterations()), 300)

    onSliderChange = (event, ui) =>
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

  onScrub: (info,opts={}) ->
    @updateActiveLine @codemirror, info.lineNumber - 1, info.frameNumber
    # updateTimelineMarker()
    # unless opts.noScroll
    #   updateTimelineScroll()

  # When given an array of messages, add CodeMirror lineWidgets to each line
  onMessages: (messages) ->
    firstMessage = messages[0]?.message
    if firstMessage
      _.map messages, (message) =>
        line = @codemirror.getLineHandle(message.lineNumber - 1)
        widgetHtml = $("<div class='line-messages'>" + message.message + "</div>")
        widget = @codemirror.addLineWidget(line, widgetHtml[0])
        @state.lineWidgets.push(widget)

  # Generate the HTML view of the timeline data structure
  # TODO: this is a bit ugly
  generateTimelineTable: (timeline) ->
    tdiv = $("#timeline")
    execLine = $("#executionLine")
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
    tableString += "<div id='tlmark'>&nbsp;</div>"
    tdiv.html(tableString)
    
    slider = @slider
    updatePreview = @updatePreview
    self = @
    updateSlider = (frameNumber) ->
      self.$( "#amount" ).text( "step #{frameNumber}" ) 
      self.state.slider.value = frameNumber
      # console.log self.state.slider.value
      updatePreview.apply(self)
    for cell in $("#timeline .content-cell")
      ((cell) -> 
        $(cell).on 'mouseover', () ->
          # TODO - this doesn't work very well
          cell = $(cell)
          frameNumber = cell.data('frame-number')
          info = {lineNumber: cell.data('line-number'), frameNumber: frameNumber}
          # @$( "#amount" ).text( "step #{ui.value}" ) 
          # @$( "#amount" ).text( "step #{ui.value}" ) 
          updateSlider info.frameNumber + 1
          # console.log(info)
          # onScrub(info, {noScroll: true})
          # state.slider.value = frameNumber + 1
          # slider.slider('value', frameNumber + 1)
          # updatePreview()
      )(cell)

    self.$("#timeline").on 'mouseenter', () ->
      $("#tlmark").show()
      $("#tlmark").height($(this).parent().height())
      $("#tlmark").css('top', '0')
      self.$("#timeline").on 'mousemove', (evt) ->
        parentOffset = $(this).parent().offset()
        relX = evt.pageX - parentOffset.left
        $("#tlmark").css('left', relX)
    self.$("#timeline").on 'mouseleave', () ->
      $("#tlmark").hide();

  onTimeline: (timeline) ->
    @generateTimelineTable(timeline)

  updatePreview: () ->
    # clear the lineWidgets (e.g. the text description)
    _.map @state.lineWidgets, (widget) -> widget.clear()

    try
      window.choc.scrub @codemirror.getValue(), @state.slider.value, 
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
    afterAll = \
      if first
        (info) =>
          count = info.frameCount
          @slider.slider('option', 'max', count)
          @slider.slider('value', count)
      else
        (info) =>
          count = info.frameCount
          @slider.slider('option', 'max', count)
          max = @slider.slider('option', 'max')
          if (@state.slider.value > max)
            @state.slider.value = max
            @slider.slider('value', max)

    window.choc.scrub @codemirror.getValue(), @options.maxIterations, 
      onTimeline: (args...) => @onTimeline.apply(@, args)
      beforeEach: (args...) => @beforeScrub.apply(@, args)
      afterEach:  (args...) => @afterScrub.apply(@, args)
      afterAll: afterAll
      locals: @options.locals

    @updatePreview()

    # if first
    #   updateTimelineScroll() 
    #   updateTimelineMarker() 

  start: () ->
    @calculateIterations(true)

root = exports ? this
root.choc.Editor = ChocEditor
