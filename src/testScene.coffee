@oc ?= {}

Octree = @oc.Octree
OctreeNode = @oc.OctreeNode


testSceneRandomNode = ->
  if Math.random() < 0.7
    color = 
      r: 0.9
      g: 0.9
      b: 0.9
    light = {r:0,g:0,b:0}
  else 
    color = 
      r: Math.random() * 0.96
      g: Math.random() * 0.96
      b: 0.5
    light = {r:0,g:0,b:0}
  @diffuseAmount = 0.1 # 0 - 1, 0: mirror, 1: shiny, 10: pretty flat, 100: etc etc
  new OctreeNode color, light, diffuseAmount


@oc.TestScene = class TestScene
  constructor: ->
    @octree = new Octree
    @octree.root.children = [
      testSceneRandomNode()
      null
      null
      testSceneRandomNode()
      null
      testSceneRandomNode()
      testSceneRandomNode()
      null
    ]
    @octree.root.children[0].children = [
      testSceneRandomNode()
      null
      null
      testSceneRandomNode()
      null
      testSceneRandomNode()
      testSceneRandomNode()
      null
    ]
    @octree.root.children[0].children[0].children = [
      testSceneRandomNode()
      null
      null
      testSceneRandomNode()
      null
      testSceneRandomNode()
      testSceneRandomNode()
      null
    ]
    @octree.root.children[3].children = [
      testSceneRandomNode()
      null
      null
      testSceneRandomNode()
      null
      testSceneRandomNode()
      testSceneRandomNode()
      null
    ]
    @octree.root.children[6].children = [
      null
      testSceneRandomNode()
      testSceneRandomNode()
      null
      testSceneRandomNode()
      null
      null
      testSceneRandomNode()
    ]


@oc.RandomScene = class RandomScene
  constructor: ->
    @octree = new Octree

    total = 0
    max = 300
    maxDepth = 40

    populate = (node,depth) =>
      return if depth > maxDepth
      node.children = []
      for i in [0...8]
        node.children[i] = if Math.random() > 0.5
          child = new OctreeNode
          total += 1
          populate child, depth+1 if Math.random() > 0.3 if total < max
          child
        else
          null

    populate @octree.root, 0


@oc.TerrainScene = class TerrainScene
  constructor: ->

    perlin = new ClassicalNoise

    @octree = new Octree

    depth = 6
    width = Math.pow 2, depth

    for x in [0...width]
      for z in [0...width]
        y = ~~( width - 4 - perlin.noise(x/10,z/10,0)*4 )
        @octree.setCell depth, [x,y,z]