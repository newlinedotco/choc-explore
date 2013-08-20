$(document).ready () ->
  choc = window.choc

  parabola = """
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

  // for(var i=0; i<100; i++) {
  //   draw();
  // }
    
  """
  canvas = document.getElementById('targetcanvas')
  pad = new Two({
    width: 200
    height: 400
    type: Two.Types.canvas
    })
    .appendTo(canvas)

  # console.log("making a pad ellipse")
  # el = pad.makeEllipse(100, 200, 30, 30) 
  # el.fill = "pink"
  # pad.update()
  # console.log("pad.update()")

  # enable retina
  if window.devicePixelRatio == 2
    canvas = pad.renderer.domElement
    canvas.setAttribute('width', canvas.width*2)
    canvas.setAttribute('height', canvas.height*2)
    pad.renderer.ctx.scale(2, 2)

  # basically we want to call draw the number of iterations times before we call update
  # we also need a hook to make everything besides the current frame fade out

  saveCanvasImage = () ->
    console.log("saving the canvas")
    dataURL = pad.renderer.domElement.toDataURL()
    console.log(pad.renderer.domElement)
    canvasbg = document.getElementById('canvasbg')
    canvasbg.src = dataURL
    $(canvasbg)
      .css('opacity', 0.2)
      .css('position', 'absolute')
      .css('width', pad.width)
      .css('height', pad.height)
      .css('top', $(canvasbg).parent().css('margin-top'))

    console.log(document.getElementById('canvasbg'))

  editor = new choc.Editor({
    $: $
    code: parabola

    beforeCodeChange: () ->
      pad.once Two.Events.render, () ->
        saveCanvasImage()

    beforeScrub: () -> 
      pad.clear()
    afterScrub: () ->  
      ball?.stroke = 'orangered'
      # console.log("pad.update()")
      pad.update()
    afterFrame: () ->
      # ball?.stroke = 'pink'
    animate: "draw"
    maxAnimationFrames: 100
    # maxIterations: 500
    # terminateWhen: () -> x > 300
    locals: { pad: pad }
    })

  # to generate the preview, draw() without beforeScrub() 
  # to scrub individually, draw() with beforeScrub()

  editor.start()

