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
    mag = Math.sqrt @x*@x + @y*@y + @z*@z
    @x/=mag
    @y/=mag
    @z/=mag
    @

Vec.randomInUnitSphere = ->
  z = 2 * Math.random() - 1
  tmp = Math.sqrt 1 - z * z
  x = Math.random() * tmp
  y = Math.random() * tmp
  new Vec x, y, z


Vec.randomInCube = ->
  new Vec(Math.random() * 2 - 1, Math.random() * 2 - 1, Math.random() * 2 - 1).normalize()
