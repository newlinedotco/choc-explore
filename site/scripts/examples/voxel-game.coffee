startVoxelDemo = (onLoaded) ->
  onLoaded ||= () ->

  container = document.getElementById("game")
  window.game = game = ChocGame(
    container: container
    playerSkin: "/images/textures/substack.png"
  )
  game.paused = false
  game.createTree({ 
    position: {x: 0, y: 14, z: 0},
    bark: 5
    leaves: 4
  })
  setTimeout((() -> game.createTree({bark: 5, leaves: 4})), 100) for [1..10]

  window.avatar.yaw.position.set 2, 28, 18 
  window.avatar.pitch.rotation = new game.THREE.Vector3(-0.44, 0, 0)

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
var material = "brick";
var radius = 3;
var floor = 14;
var height = 10;
var x = 0;
var y = floor;
var z = 0;
var l = radius * Math.cos(Math.PI / 4);
while( y <= height+floor) {
  while( x <= l ) {
    z = Math.sqrt((radius*radius) - (x*x));
    setBlock([x, y, z], material);
    setBlock([x, y, -z], material);
    setBlock([-x, y, z], material);
    setBlock([-x, y, -z], material);

    setBlock([z, y, x], material);
    setBlock([z, y, -x], material);
    setBlock([-z, y, x], material);
    setBlock([-z, y, -x], material);
    x = x + 1;
  }
  x = 0;
  y = y + 1;
}


  """

  editor = new window.choc.Editor({
    $: $
    id: "#choc-editor-for-voxel"
    code: code
    beforeScrub: () -> clearNewBlocks()
    afterScrub: () -> 
    locals: { game: game, setBlock: setBlock }
    onLoaded: () -> onLoaded()
    })

  editor.start()

window.ChocGame ||= {}
window.ChocGame.startVoxelDemo = startVoxelDemo

