$(document).ready () ->
  choc = window.choc

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
  previewPad.renderer.ctx.globalAlpha = 0.5;
  previewPad.renderer.ctx.globalCompositeOperation = "lighter"

  editor = new choc.AnimationEditor({
    $: $
    code: code
    beforeGeneratePreview: () ->
      previewPad.clear()
    beforeScrub: () -> 
      pad.clear()
    afterScrub: () ->  
      ball?.stroke = 'orangered'
      pad.update()
    afterFrame: () ->
      # ball?.stroke = 'pink'
    animate: "draw"
    maxAnimationFrames: 100
    # maxIterations: 500
    # terminateWhen: () -> x > 300
    locals: { pad: [framePad, previewPad] }
    })

  # to generate the preview, draw() without beforeScrub() 
  # to scrub individually, draw() with beforeScrub()

  editor.start()

  # have a bg canvas
  # and a fg canvas
  # set the global opacity on the bg context to be 50%
  # when the code changes run on the bg canvas  
  # when the scrub changes run the draw the number of times to the frame
  # say frame number in the slider
  # have the ability to change the number of animation frames
  # have a play button to play the animation

