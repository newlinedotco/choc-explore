class ChocEditor
  WRAP_CLASS = "CodeMirror-activeline"

  constructor: (options) ->
    @options = options
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
      # @state.delay = setTimeout(@calculateIterations, 300)

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
    # if @state.timeline.activeLine
    #   @state.timeline.activeLine.removeClass("active")
    # if @state.timeline.activeFrame
    #   @state.timeline.activeFrame.removeClass("active")

  updateActiveLine: (cm, lineNumber, frameNumber) ->
    line = @$(@$(".CodeMirror-lines pre")[lineNumber])
    return if cm.state.activeLine is line
    @clearActiveLine()
    line.addClass(WRAP_CLASS) if line
    @state.editor.activeLine = line

    # state.timeline.activeLine = $($("#timeline table tr")[lineNumber + 1])
    # state.timeline.activeLine.addClass("active") if state.timeline.activeLine
    
    # update active frame
    #                                                            plus one for header, plus one for 1-indexed css selector
    # state.timeline.activeFrame = $("#timeline table tr:nth-child(#{lineNumber + 1 + 1}) td:nth-child(#{frameNumber + 1}) .cell")
    # splitting this up into three 'queries' is a lot faster than one giant query (in my profiling in Chrome)
    # activeRow   = @$("#timeline table tr")[lineNumber + 1]
    # activeTd    = @$(activeRow).find("td")[frameNumber]
    # activeFrame = @$(activeTd).find(".cell")
    # state.timeline.activeFrame = activeFrame
    # state.timeline.activeFrame.addClass("active") if state.timeline.activeFrame

  onScrub: (info,opts={}) ->
    console.log(info)
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
    inf = 1000

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

    window.choc.scrub @codemirror.getValue(), inf, 
      # onTimeline: () => @onTimeline()
      beforeEach: () => @beforeScrub()
      afterEach: () => @afterScrub()
      afterAll: afterAll
      locals: @options.locals

    @updatePreview()

    # if first
    #   updateTimelineScroll() 
    #   updateTimelineMarker() 

    # first time 
    # calculateIterations(true)

  start: () ->
    @calculateIterations(true)

root = exports ? this
# root.choc ||= {}
root.choc.Editor = ChocEditor
