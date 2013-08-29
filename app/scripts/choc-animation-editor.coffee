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
      playing: false
    @setupEditor()

  changeSlider: (newValue) ->
    @$( "#amount" ).text( "frame #{newValue}" ) 
    @state.slider.value = newValue
    @updateFrameView()

  setupEditor: () ->
    @interactiveValues = {
      onChange: (v) =>
        clearTimeout(@state.delay)
        @state.delay = setTimeout((() => @updateViews()), 1)
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
      @state.delay = setTimeout((() => @updateViews()), 500)

    onSliderChange = (event, ui) =>
      if event.hasOwnProperty("originalEvent") # e.g. triggered by a user interaction, not programmatically below
        @changeSlider(ui.value)

    @slider = @$("#slider").slider {
      min: 0
      max: @options.maxAnimationFrames
      change: onSliderChange
      slide: onSliderChange
      }

    @$("#animation-controls").click () =>
      if @state.playing
        console.log("pause")
        @state.playing = false
        @options.pause()
        @updateViews()
      else
        @updateViews()
        console.log("play")
        @state.playing = true
        @options.play()

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

  updateFrameView: () ->
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
    gval(localsStr + "\n" + code )

  updateViews: () ->
    @generatePreview()
    @updateFrameView()

  generatePreview: () ->
    gval = eval

    @options.beforeGeneratePreview?()
    @runCode(@codemirror.getValue(), true)
    draw = gval(@options.animate)
    do (() -> draw()) for [1..@options.maxAnimationFrames]

    @options.afterGeneratePreview?()

  start: () ->
    @changeSlider(1)
    @updateViews()

root = exports ? this
root.choc.AnimationEditor = ChocAnimationEditor
