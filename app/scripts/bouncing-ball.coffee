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

  for(var i=0; i<100; i++) {
    draw();
  }
    
  """
  canvas = document.getElementById('targetcanvas')
  pad = new Two({
    width: 200
    height: 400
    type: Two.Types.canvas
    })
    .appendTo(canvas)
  console.log("making a pad ellipse")
  el = pad.makeEllipse(100, 200, 30, 30) 
  el.fill = "pink"

  pad.update()

  # enable retina
  if window.devicePixelRatio == 2
    canvas = pad.renderer.domElement
    canvas.setAttribute('width', canvas.width*2)
    canvas.setAttribute('height', canvas.height*2)
    pad.renderer.ctx.scale(2, 2)

  # basically we want to call draw the number of iterations times before we call update
  # we also need a hook to make everything besides the current frame fade out

  editor = new choc.Editor({
    $: $
    code: parabola
    afterCalculatingIterations: () ->
      console.log("saving the canvas")
      dataURL = pad.renderer.domElement.toDataURL()
      console.log(pad.renderer.domElement)
      console.log(dataURL)
      document.getElementById('canvasbg').src = dataURL
      console.log(document.getElementById('canvasbg').src)
      console.log(document.getElementById('canvasbg'))
    beforeScrub: () -> 
      # pad.clear()
    afterScrub: () ->  
      # ball?.stroke = 'orangered'
      pad.update()
    afterFrame: () ->
      # ball?.stroke = 'pink'
    animate: "draw"
    # maxIterations: 500
    # terminateWhen: () -> x > 300
    locals: { pad: pad }
    })

  editor.start()

