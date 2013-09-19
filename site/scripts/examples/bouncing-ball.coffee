$(document).ready () ->
  choc = window.choc
  geval = eval

  code = """
   var draw, ball, x = 0, y = 50, dy = 0;
   draw = function() {
     x += 3;
     y += dy; 
     if (y > 185) {
       dy = -dy;
       ball = pad.makeEllipse(x, 190, 36, 25); 
     } else {
       dy = dy * 0.94 + 3;
       ball = pad.makeEllipse(x, y, 30, 30); 
     }
   }

  """
  twoOptions = 
    width: 200
    height: 400
    type: Two.Types.canvas

  framePad   = new Two(twoOptions).appendTo(document.getElementById('frameCanvas'))
  previewPad = new Two(twoOptions).appendTo(document.getElementById('previewCanvas'))

  $("#fader").width(twoOptions.width).height(twoOptions.height)

  maxAnimationFrames = 100

  editor = new choc.AnimationEditor({
    $: $
    id: "#choc-editor-for-bouncing-ball"
    code: code
    beforeGeneratePreview: () -> previewPad.clear()
    afterGeneratePreview:  () -> previewPad.update()

    animate: "draw"
    play: () ->
      draw = geval("draw")
      framePad.frameCount = 0

      editor.start()
      previewPad.clear()

      updateFn = (frameCount, timeDelta) ->
        if frameCount > maxAnimationFrames
          editor.onPause()
        else
          editor.onFrame(frameCount, timeDelta)
          _.defer () ->
            framePad.clear()
            draw()

      framePad.unbind(Two.Events.update)
      framePad.bind('update', updateFn)
      framePad.play()
    pause: () ->
      framePad.pause()
      framePad.unbind(Two.Events.update)

    maxAnimationFrames: maxAnimationFrames
    locals: { pad: [framePad, previewPad] }
    })

  editor.start()
