@oc ?= {}

# these run faster than Math.max/min and overloading arguments
# max = (arr) ->
#   rval = -Infinity
#   for val in arr
#     if val > rval then rval = val
#   rval

# min = (arr) ->
#   rval = Infinity
#   for val in arr
#     if val < rval then rval = val
#   rval

max = (a,b) -> if a > b then a else b
min = (a,b) -> if a < b then a else b


NO_COLLISON = dist: Infinity, node: null, tVals: null


class @oc.Octree
  constructor: ->
    @root = new window.oc.OctreeNode
    @children = null

  castRay: (r) ->
    lb = x:0, y:0, z:0
    rt = x:1, y:1, z:1
    @root.castRay r, 0, lb, rt

  setCell: (targetDepth, targetCoords) ->
    @root.setCell 0, targetDepth, [0,0,0], targetCoords


class @oc.OctreeNode
  constructor: ->
    @children = null
    if Math.random() < 0.7
      @color = 
        r: 0.9
        g: 0.9
        b: 0.9
      @light = {r:0,g:0,b:0}
    else 
      @color = 
        r: Math.random() * 0.96
        g: Math.random() * 0.96
        b: 0.5
      @light = {r:0,g:0,b:0}
      #@light = {r:4,g:4,b:4}


  setCell: (myDepth, targetDepth, myCoords, targetCoords) ->

    # we will only ever get to the target depth if we are the right node.
    # return this? also, should we truncate children if this 
    # is called on a node with children, and make it terminal?
    if myDepth == targetDepth then return

    # here we do some clever math to determine the next child
    # convert the target coords, and myCoords, into our child space, round down, 
    # and subtract to get child in range of [0,0,0] -> [1,1,1]
    depthRemaining = targetDepth - myDepth

    targetCoordsInChildSpace = for j in [0...3]
      ~~( targetCoords[j] / Math.pow(2,depthRemaining-1) )

    myCoordsInChildSpace = for j in [0...3]
      myCoords[j] * 2

    childOffset = for j in [0...3]
      targetCoordsInChildSpace[j] - myCoordsInChildSpace[j]

    childIndex = childOffset[0] + childOffset[1]*2 + childOffset[2]*4

    debugger if childIndex >= 8

    # create the next child node if we haven't yet
    @children ?= [null,null,null,null,null,null,null,null]
    @children[ childIndex ] ?= new OctreeNode

    @children[ childIndex ].setCell myDepth+1, targetDepth, targetCoordsInChildSpace, targetCoords


  castRay: (r,currentDepth,lb,rt) ->

    collision = @rayBoxIntersect lb, rt, r
    return collision if collision.dist == Infinity # we missed
    
    # we hit a terminal cell (yay)
    if @children == null
      # apply the diffuse color of this node
      return collision
    
    #else, we need to look in the child nodes

    nextDepth = currentDepth + 1
    closestChildCollision = NO_COLLISON

    for c,i in @children # TODO: test performance of [0...8]

      continue if c == null

      # clever shortcut for generating all 8 cube offsets
      cx = ~~(i%2)
      cy = ~~(i/2)%2
      cz = ~~(i/4)%2

      nextScale = 1/Math.pow(2,nextDepth)

      lb2 =
        x: lb.x + cx * nextScale
        y: lb.y + cy * nextScale
        z: lb.z + cz * nextScale
      rt2 =
        x: lb2.x + nextScale
        y: lb2.y + nextScale
        z: lb2.z + nextScale

      childCollision = c.castRay(r,nextDepth,lb2,rt2)

      if childCollision.dist < closestChildCollision.dist
        closestChildCollision = childCollision

    return closestChildCollision


  # lb: box corner 1
  # rt: box corner 2
  # r: ray
  # returns: distance to instersection, or Infinity if no intersection
  rayBoxIntersect: (lb,rt,r) ->
    # r.dir is unit direction vector of ray
    dirfracX = 1.0 / r.dir.x
    dirfracY = 1.0 / r.dir.y
    dirfracZ = 1.0 / r.dir.z
    # lb is the corner of AABB with minimal coordinates - left bottom, rt is maximal corner
    # r.org is origin of ray

    t1 = (lb.x - r.org.x)*dirfracX
    t2 = (rt.x - r.org.x)*dirfracX
    t3 = (lb.y - r.org.y)*dirfracY
    t4 = (rt.y - r.org.y)*dirfracY
    t5 = (lb.z - r.org.z)*dirfracZ
    t6 = (rt.z - r.org.z)*dirfracZ


    tmax = min( min( max( t1, t2 ), max( t3, t4 ) ), max( t5, t6 ) )
    return NO_COLLISON if tmax < 0
    tmin = max( max( min( t1, t2 ), min( t3, t4 ) ), min( t5, t6 ) )
    return NO_COLLISON if tmin > tmax

    # so we can cheaply get the normal later when we determine which node was hit
    tVals = [t1,t2,t3,t4,t5,t6]

    return dist: tmin, node: @, tVals: tVals
