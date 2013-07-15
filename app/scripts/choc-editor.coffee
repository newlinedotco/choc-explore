class ChocEditor
  WRAP_CLASS = "CodeMirror-activeline"
  BACK_CLASS = "CodeMirror-activeline-background"

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

  onScrub: (info,opts={}) ->
    # updateActiveLine @codemirror, info.lineNumber - 1, info.frameNumber
    # updateTimelineMarker()
    # unless opts.noScroll
    #   updateTimelineScroll()

  # When given an array of messages, add CodeMirror lineWidgets to each line
  onMessages: (messages) ->
    # firstMessage = messages[0]?.message
    # if firstMessage
    #   _.map messages, (message) ->
    #     line = @codemirror.getLineHandle(message.lineNumber - 1)
    #     widgetHtml = $("<div class='line-messages'>" + message.message + "</div>")
    #     widget = @codemirror.addLineWidget(line, widgetHtml[0])
    #     @state.lineWidgets.push(widget)

  updatePreview: () ->
    # clear the lineWidgets (e.g. the text description)
    _.map @state.lineWidgets, (widget) -> widget.clear()

    try
      window.choc.scrub @codemirror.getValue(), @state.slider.value, 
        onFrame: () => @onScrub()
        beforeEach: () => @beforeScrub()
        afterEach: () => @afterScrub()
        onMessages: () => @onMessages()
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
