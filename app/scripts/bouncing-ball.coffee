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
  fader      = new Two(twoOptions).appendTo(document.getElementById('faderCanvas'))
  previewPad = new Two(twoOptions).appendTo(document.getElementById('previewCanvas'))

  window.framePad = framePad

  rectangle = fader.makeRectangle(fader.width/2,fader.height/2, fader.width, fader.height)
  rectangle.fill = "rgba(255, 255, 255, 0.50)"
  fader.update()

  editor = new choc.AnimationEditor({
    $: $
    code: code
    beforeGeneratePreview: () -> previewPad.clear()
    afterGeneratePreview:  () -> previewPad.update()

    animate: "draw"
    play: (cb) ->
      framePad.frameCount = 0
      previewPad.clear()
      previewPad.update()
      draw = geval("draw")
      updateFn = (frameCount, timeDelta) ->

        if frameCount > 100
          framePad.pause()
        else
          _.defer () ->
            framePad.clear()
            draw()

      framePad.unbind(Two.Events.update)
      framePad.bind('update', updateFn)
      framePad.play()
    pause: () ->
      framePad.pause()
      # framePad.unbind(Two.Events.update)

    maxAnimationFrames: 100
    locals: { pad: [framePad, previewPad] }
    })

  # to generate the preview, draw() without beforeScrub() 
  # to scrub individually, draw() with beforeScrub()

  editor.start()
