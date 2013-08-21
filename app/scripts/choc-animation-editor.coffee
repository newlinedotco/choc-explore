class ChocAnimationEditor

  constructor: (options) ->
    defaults =
      maxIterations: 1000
      maxAnimationFrames: 100

    @options = _.extend(defaults, options)
    @$ = options.$
    @state = 
      delay: null
      slider:
        value: 0
    @setupEditor()

  setupEditor: () ->
    @interactiveValues = {
      onChange: (v) =>
        clearTimeout(@state.delay)
        @state.delay = setTimeout(
          (() => 
            @generatePreview()), 
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
      @state.delay = setTimeout((() => @generatePreview()), 500)

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

  beforeScrub: () -> @options.beforeScrub()
  afterScrub: () -> @options.afterScrub()
  updateActiveLine: (cm, lineNumber, frameNumber) ->
  updateTimelineMarker: (activeFrame) ->
  onScrub: (info,opts={}) ->

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

  updatePreview: () ->
    try
      code = @codemirror.getValue()
      if @options.animate?
        appendSource = """
          for(var __i=0; __i<#{@options.maxAnimationFrames}; __i++) {
            pad.clear();
            #{@options.animate}();
            pad.update();
          }
        """

      window.choc.scrub code, @state.slider.value, 
        onFrame:    (args...) => @onScrub.apply(@, args)
        beforeEach: (args...) => @beforeScrub.apply(@, args)
        afterEach:  (args...) => @afterScrub.apply(@, args)
        onMessages: (args...) => @onMessages.apply(@, args)
        locals: @options.locals
        appendSource: appendSource || ""
      @$("#messages").text("")
    catch e
      console.log(e)
      console.log(e.stack)
      @$("#messages").text(e.toString())

  generatePreview: (first=false) ->
    # afterAll = () -> 
    # if first
    #   afterAll = (info) =>
    #     count = info.frameCount
    #     @slider.slider('option', 'max', count)
    #     @slider.slider('value', count)
    # else
    #   afterAll = (info) =>
    #     count = info.frameCount
    #     @slider.slider('option', 'max', count)
    #     max = @slider.slider('option', 'max')
    #     if (@state.slider.value > max)
    #       @state.slider.value = max
    #       @slider.slider('value', max)
    #       @slider.slider('step', count)
    @options.beforeGeneratePreview?()

    window._choc_preview_locals = @options.locals
    # console.log(@options.locals)
    localsStr = _.map(_.keys(@options.locals), (name) -> "var #{name} = _choc_preview_locals.#{name}[1]; console.log(#{name});").join("; ")
    gval = eval
    # console.log(localsStr)
    gval(localsStr + "\n" + @codemirror.getValue())
    draw = gval(@options.animate)
    do (() -> draw()) for [1..@options.maxAnimationFrames]

    @options.afterGeneratePreview?()

    # @options.beforeCodeChange()
    # _.defer () => @updatePreview() # ew two.js...

  start: () ->
    @generatePreview(true)

root = exports ? this
root.choc.AnimationEditor = ChocAnimationEditor

# when the page loads
# run the animation F number of times
# save the image off-scene and ghost it  - actually
# pass in the canvas / context
# set the global opacity and just put the canvas under the other canvas
# 
