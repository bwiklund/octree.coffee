@oc ?= {}

Octree = @oc.Octree
OctreeNode = @oc.OctreeNode

@oc.TestScene = class TestScene
  constructor: ->
    @octree = new Octree
    @octree.root.children = [
      new OctreeNode
      null
      null
      new OctreeNode
      null
      new OctreeNode
      new OctreeNode
      null
    ]
    @octree.root.children[0].children = [
      new OctreeNode
      null
      null
      new OctreeNode
      null
      new OctreeNode
      new OctreeNode
      null
    ]
    @octree.root.children[0].children[0].children = [
      new OctreeNode
      null
      null
      new OctreeNode
      null
      new OctreeNode
      new OctreeNode
      null
    ]
    @octree.root.children[3].children = [
      new OctreeNode
      null
      null
      new OctreeNode
      null
      new OctreeNode
      new OctreeNode
      null
    ]
    @octree.root.children[6].children = [
      null
      new OctreeNode
      new OctreeNode
      null
      new OctreeNode
      null
      null
      new OctreeNode
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
    @octree = new Octree

    depth = 4
    width = Math.pow 2, depth

    for y in [0...width]
      for x in [0...width]
        @octree.setCell depth, [x,y,0]