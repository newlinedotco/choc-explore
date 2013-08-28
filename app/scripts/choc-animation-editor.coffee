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
        @$( "#amount" ).text( "frame #{ui.value}" ) 
        @state.slider.value = ui.value
        @updatePreview()

    @slider = @$("#slider").slider {
      min: 0
      max: @options.maxAnimationFrames
      change: onSliderChange
      slide: onSliderChange
      }

  # beforeScrub: () -> @options.beforeScrub()
  # afterScrub: () -> @options.afterScrub()
  # updateActiveLine: (cm, lineNumber, frameNumber) ->
  # updateTimelineMarker: (activeFrame) ->
  # onScrub: (info,opts={}) ->

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
        # below we run animate for every iteration to make sure we're at the
        # right place in code. However, we don't clear/update everytime because
        # it causes flashing. We only need to clear right before we draw the
        # frame we want to see
        appendSource = """
          for(var __i=0; __i<#{@state.slider.value}; __i++) {
            if(__i == #{@state.slider.value - 1}) {
              pad.clear();
              #{@options.animate}();
              pad.update();
            } else {
            #{@options.animate}();
            }
          }
        """

      @runCode(@codemirror.getValue() + appendSource, false)

      @$("#messages").text("")
    catch e
      console.log(e)
      console.log(e.stack)
      @$("#messages").text(e.toString())

  runCode: (code, isPreview=false) ->
    gval = eval

    localsIndex = if isPreview then 1 else 0

    window._choc_preview_locals = @options.locals
    localsStr = _.map( _.keys(@options.locals), \
                (name) -> 
                  "var #{name} = _choc_preview_locals.#{name}[#{localsIndex}]").join("; ")
    console.log(localsStr)
    gval(localsStr + "\n" + code )


  generatePreview: (first=false) ->
    gval = eval

    @options.beforeGeneratePreview?()

    @runCode(@codemirror.getValue(), true)

    draw = gval(@options.animate)
    do (() -> draw()) for [1..@options.maxAnimationFrames]

    @options.afterGeneratePreview?()

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
