describe "octree", ->

  Octree = window.oc.Octree
  OctreeNode = window.oc.OctreeNode
  Ray = window.oc.Ray


  it "exists", ->
    expect( new Octree ).not.toBe( null )


  it "can collide against the root node", ->
    octree = new Octree
    ray = new Ray {x:0.5,y:0.5,z:-2}, {x:0,y:0,z:1}

    expect( octree.castRay( ray ).dist ).toBe( 2 )


  it "can collide against deeper nodes", ->
    octree = new Octree
    ray = new Ray {x:0.25,y:0.25,z:-1}, {x:0,y:0,z:1}
    octree.root.children = [
      null
      null
      null
      null
      new OctreeNode
      null
      null
    ]

    expect( octree.castRay( ray ).dist ).toBe( 1.5 )


  describe "setCell", ->

    # a bunch of cases and edge cases are represented here, should probably be dried up

    it "works on 0 [0,0,0]", ->
      octree = new Octree
      octree.setCell 0, [0,0,0]
      expect( octree.root ).not.toBeNull()

    it "works on 1 [0,0,0]", ->
      octree = new Octree
      octree.setCell 1, [0,0,0]
      expect( octree.root.children[0] ).not.toBeNull()

    it "works on 2 [0,0,0]", ->
      octree = new Octree
      octree.setCell 2, [0,0,0]
      expect( octree.root.children[0].children[0] ).not.toBeNull()

    it "works on 2 [3,3,3]", ->
      octree = new Octree
      octree.setCell 2, [3,3,3]
      expect( octree.root.children[7].children[7] ).not.toBeNull()

    it "works on 2 [1,1,1]", ->
      octree = new Octree
      octree.setCell 2, [1,1,1]
      expect( octree.root.children[0].children[7] ).not.toBeNull()

    it "works on 2 [2,2,2]", ->
      octree = new Octree
      octree.setCell 2, [2,2,2]
      expect( octree.root.children[7].children[0] ).not.toBeNull()

    it "works on 3 [2,2,2]", ->
      octree = new Octree
      octree.setCell 3, [2,2,2]
      expect( octree.root.children[0].children[7].children[0] ).not.toBeNull()
