
$(document).ready ->
  choc = window.choc

  container = document.getElementById("game")
  window.game = game = ChocGame(
    container: container
    playerSkin: "/images/textures/substack.png"
  )

  game.createTree({ 
    position: {x: 0, y: 14, z: 0},
    bark: 5
    leaves: 4
  })

  newBlocks = []

  setBlock = (pos, type) ->
    type = switch type 
      when "clear" then 0 
      when "grass" then 1 
      when "brick" then 2
      when "bark" then 3
      when "leaves" then 4
      else type
    newBlocks.push [pos, game.getBlock(pos)] 
    game.setBlock(pos, type)

  setBlock.__choc_annotation = (args) ->
    [pos, type] = args
    posStr = _.map(pos, (p) -> "<span class='choc-variable'>#{p}</span>").join(", ")
    "set (#{posStr}) to #{type}"

  clearNewBlocks = () ->
    for item in newBlocks.reverse()
      [pos,type] = item
      game.setBlock(pos, type)
    newBlocks = []

  code = """
    var count = 10;
    for(var i=0; i<count; i++) {
      setBlock([i,14,0], "brick");
    }
  """

  circle1 = """
    var radius = 5; 
    var x;
    var y;

    for (y = -radius; y <= radius; y++) {
      console.log(y);
      for (x = -radius; x <= radius; x++) {
        console.log(x);
        var thing = (x*x) + (y*y) <= (radius*radius);
        if( thing ) {
          console.log(x, y);
          setBlock([x,16,y], 2);
        }
      }
    }
  """

  # notes: Math.round y to fix the bug
  circle2 = """
    var radius = 17;
    var x = 0;
    var y = 0;
    var material = "brick";
    var floor = 14;
    var l = radius * Math.cos(Math.PI / 4);
    while(x<=l) {
      y = Math.sqrt((radius*radius) - (x*x));
      setBlock([x, floor, y], material);
      setBlock([x, floor, -y], material);
      setBlock([-x, floor, y], material);
      setBlock([-x, floor, -y], material);

      setBlock([y, floor, x], material);
      setBlock([y, floor, -x], material);
      setBlock([-y, floor, x], material);
      setBlock([-y, floor, -x], material);  
      x++;
    }
  """

  editor = new choc.Editor({
    $: $
    #code: code
    code: circle2
    beforeScrub: () -> clearNewBlocks()
    afterScrub: () ->  # pad.update()
    # afterEdit () -> clearNewBlocks()
    locals: { game: game, setBlock: setBlock }
    })

  editor.start()

