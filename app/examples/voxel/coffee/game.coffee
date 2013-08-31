#; createGame = require('voxel-hello-world')
#game = createGame()

createGame = require("voxel-engine")
highlight = require("voxel-highlight")
player = require("voxel-player")
voxel = require("voxel")
extend = require("extend")
fly = require("voxel-fly")
walk = require("voxel-walk")
texturePath = require('painterly-textures')
createTree = require("voxel-forest")

# setup the game and add some trees
# for debugging

# create the player from a minecraft skin file and tell the
# game to use it as the main player
defaultSetup = (game, avatar) ->
  makeFly = fly(game)
  target = game.controls.target()
  game.flyer = makeFly(target)
  
  # highlight blocks when you look at them, hold <Ctrl> for block placement
  blockPosPlace = undefined
  blockPosErase = undefined
  hl = game.highlighter = highlight(game,
    color: 0xff0000
  )
  hl.on "highlight", (voxelPos) ->
    blockPosErase = voxelPos

  hl.on "remove", (voxelPos) ->
    blockPosErase = null

  hl.on "highlight-adjacent", (voxelPos) ->
    blockPosPlace = voxelPos

  hl.on "remove-adjacent", (voxelPos) ->
    blockPosPlace = null

  
  # toggle between first and third person modes
  window.addEventListener "keydown", (ev) ->
    avatar.toggle()  if ev.keyCode is "R".charCodeAt(0)

  
  # block interaction stuff, uses highlight data
  currentMaterial = 1
  game.on "fire", (target, state) ->
    position = blockPosPlace
    if position
      game.createBlock position, currentMaterial
    else
      position = blockPosErase
      game.setBlock position, 0  if position

  game.on "tick", ->
    walk.render target.playerSkin
    vx = Math.abs(target.velocity.x)
    vz = Math.abs(target.velocity.z)
    if vx > 0.001 or vz > 0.001
      walk.stopWalking()
    else
      walk.startWalking()

ChocGame = (opts, setup) ->
  setup = setup or defaultSetup
  defaults =
    generate: (x,y,z) ->
      if y < 14 then 1 else 0 
    chunkDistance: 2
    materials: [['grass', 'dirt', 'grass_dirt'], 'brick', 'dirt', 'leaves_opaque', 'tree_side']
    materialFlatColor: false
    texturePath: "/images/textures/" # texturePath()
    worldOrigin: [0, 0, 0]
    controls:
      discreteFire: true

  opts = extend({}, defaults, opts or {})
  game = createGame(opts)
  container = opts.container or document.body
  window.game = game
  game.appendTo container
  return game  if game.notCapable()
  createPlayer = player(game)
  avatar = createPlayer(opts.playerSkin or "/node_modules/voxel-player/example/static/substack.png")
  avatar.possess()
  avatar.yaw.position.set 2, 14, 4
  setup game, avatar
  window.avatar = avatar
  game


module.exports = ChocGame

$(document).ready ->
  container = document.getElementById("game")
  game = ChocGame(
    container: container
  )

  createTree(game, { 
    position: {x: 0, y: 14, z: 0},
    bark: 5
    leaves: 4
  })

  # snow = require("voxel-snow")(
  #   game: game # pass it a copy of the game
  #   count: 1000 # how many particles of snow
  #   size: 20 # size of snowfall
  #   speed: 0.1 # speed it falls
  #   drift: 1 # speed it drifts
  #   material: game.THREE.ParticleBasicMaterial( # material of the particle
  #     color: 0xffffff
  #     size: 1
  #   )
  # )
  # game.on "tick", ->
  #   snow.tick() # update the snow by calling tick


# 
window.createTree = createTree
window.game = game
