Vec = @oc.Vec

describe "vec", ->

  it "exists", ->
    expect( Vec ).toBeDefined()

  it "can add", ->
    expect( new Vec(1,2,3).add new Vec(2,3,4) ).toEqual new Vec 3,5,7

  it "can multiply", ->
    expect( new Vec(1,2,3).mult 5 ).toEqual new Vec 5,10,15

  it "can normalize", ->
    x = 4 / Math.sqrt 4*4*3
    expect( new Vec(4,4,4).normalize() ).toEqual new Vec x,x,x