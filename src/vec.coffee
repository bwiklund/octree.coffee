@oc ?= {}


@oc.Vec = class Vec
  constructor: (@x,@y,@z) ->

  get: ->
    new Vec @x, @y, @z

  mult: (n) ->
    @x *= n
    @y *= n
    @z *= n
    @

  add: (v) ->
    @x += v.x
    @y += v.y
    @z += v.z
    @

  normalize: ->
    mag = @mag()
    @x/=mag
    @y/=mag
    @z/=mag
    @

  mag: ->
    Math.sqrt @x*@x + @y*@y + @z*@z

Vec.randomUnitVector = ->
  theta = Math.random() * 2 * Math.PI
  r = Math.sqrt( Math.random() )
  z = Math.sqrt( 1 - r*r ) * if Math.random() > 0.5 then 1 else -1 # todo: cleverer math without conditional?
  new Vec r * Math.cos(theta), r * Math.sin(theta), z

Vec.randomInCube = ->
  new Vec(Math.random() * 2 - 1, Math.random() * 2 - 1, Math.random() * 2 - 1)
