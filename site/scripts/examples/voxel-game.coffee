startVoxelDemo = () ->

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
  window.avatar.yaw.position.set 5, 21, 16 

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

  # notes: use Math.round y to fix the bug
  # left the bug in to show how one can use choc to find these sorts of bugs
  code = """
var radius = 3;
var x = 0;
var y = 0;
var material = "brick";
var floor = 14;
var z = floor;
var height = 10;
var l = radius * Math.cos(Math.PI / 4);
while( z <= height+floor) {
  while( x<=l ) {
    y = Math.sqrt((radius*radius) - (x*x));
    setBlock([x, z, y], material);
    setBlock([x, z, -y], material);
    setBlock([-x, z, y], material);
    setBlock([-x, z, -y], material);

    setBlock([y, z, x], material);
    setBlock([y, z, -x], material);
    setBlock([-y, z, x], material);
    setBlock([-y, z, -x], material);
    x = x + 1;
  }
  x = 0;
  z = z + 1;
}


  """

  editor = new window.choc.Editor({
    $: $
    id: "#choc-editor-for-voxel"
    code: code
    beforeScrub: () -> clearNewBlocks()
    afterScrub: () -> 
    locals: { game: game, setBlock: setBlock }
    })

  editor.start()

window.Choc ||= {}
window.Choc.startVoxelDemo = startVoxelDemo

