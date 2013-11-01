Ray = @oc.Ray
Octree = @oc.Octree
OctreeNode = @oc.OctreeNode
Vec = @oc.Vec

TestScene = @oc.TestScene
TerrainScene = @oc.TerrainScene


class Skybox
  constructor: (@src,onLoaded) ->
    @image = new Image
    @image.src = @src
    @image.onload = => 
      @loadImageData()
      onLoaded()

  loadImageData: ->
    canvas = document.createElement 'canvas'
    ctx = canvas.getContext '2d'
    canvas.width = @image.width
    canvas.height = @image.height
    ctx.drawImage @image, 0, 0, canvas.width, canvas.height
    @imageData = ctx.getImageData 0, 0, canvas.width, canvas.height
    @data = @imageData.data

  getColorForDir: (dir) ->
    u = Math.atan2( dir.z, -dir.x ) / Math.PI / 2 + 0.5
    v = dir.y/2 + 0.5
    ix = ~~( u * @image.width )
    iy = ~~( v * @image.height )
    i = 4 * (iy * @image.width + ix)
    return {
      r: @data[i+0]/255
      g: @data[i+1]/255
      b: @data[i+2]/255
    }


class Renderer
  constructor: ->
    @canvas = document.createElement('canvas')
    @a = @canvas.getContext '2d'

    @w = @canvas.width = 299
    @h = @canvas.height = 299

    @imageData = @a.getImageData 0,0,@w,@h
    @data = @imageData.data

    @buffer = new Float32Array (0 for i in [0..@w*@h*3])
    @numPasses = 0


  updateStats: ->
    @bouncesPerSecond = (@bouncesLastPass)/(@endTime - @startTime)/1000
    document.title = "P#{@numPasses} | #{@endTime - @startTime}ms | #{@bouncesPerSecond.toFixed(2)}Mpps"


  updateImageData: ->
    for i in [0..@h*@w]
      bufferI = 3 * i
      imageDataI = 4 * i

      @data[imageDataI+0] = 255 * @buffer[bufferI+0] / @numPasses
      @data[imageDataI+1] = 255 * @buffer[bufferI+1] / @numPasses
      @data[imageDataI+2] = 255 * @buffer[bufferI+2] / @numPasses
      @data[imageDataI+3] = 255

    @a.putImageData @imageData, 0, 0


  doPass: ->

    @numPasses += 1
    @maxBounces = 10
    @bouncesLastPass = 0

    @startTime = new Date

    pixelCount = @h*@w
    for i in [0...pixelCount]
      ix = i%@w
      iy = ~~(i/@w)

      fov = 0.5

      dir = new Vec ix / @w - 0.5, iy / @h - 0.5, fov
      dir.x += 1 * Math.random() / @w #aa
      dir.y += 1 * Math.random() / @w #aa
      dir.normalize()

      org = new Vec 0.51, 0.51, -0.6

      color = {r:1,g:1,b:1}
      light = {r:0,g:0,b:0}


      for bounce in [0...@maxBounces]
        @bouncesLastPass += 1

        ray = new Ray org, dir, color, light

        collision = @scene.octree.castRay ray

        # added fog. if this distance is shorter than collisionDist, then bounce randomly instead
        # foggyCollision = Infinity#if Math.random() < 0.5 then Math.random()*1 else Infinity

        # if foggyCollision < collision.dist
        #   org = org.get().add( foggyCollision-0.0000001 )
        #   dir = Vec.randomInUnitSphere()

        if collision.dist != Infinity

          nodeColor = collision.node.color
          ray.color.r *= nodeColor.r
          ray.color.g *= nodeColor.g
          ray.color.b *= nodeColor.b

          nodeLight = collision.node.light
          ray.light.r += nodeLight.r
          ray.light.g += nodeLight.g
          ray.light.b += nodeLight.b

          org = org.get().add( dir.mult(collision.dist-0.0000001) )

          # diffuse
          diffuser = Vec.randomInUnitSphere()

          diffuseAmount = 10#0.1 # 0 - 1, 0: mirror, 1: shiny, 10: pretty flat, 100: etc etc

          # make the reflective vector. also, ensure that the diffuse vector is pointing away from the normal
          if      collision.dist == collision.tVals[0] then dir.x *= -1; diffuser.x = -Math.abs(diffuser.x)
          else if collision.dist == collision.tVals[1] then dir.x *= -1; diffuser.x =  Math.abs(diffuser.x)
          else if collision.dist == collision.tVals[2] then dir.y *= -1; diffuser.y = -Math.abs(diffuser.y)
          else if collision.dist == collision.tVals[3] then dir.y *= -1; diffuser.y =  Math.abs(diffuser.y)
          else if collision.dist == collision.tVals[4] then dir.z *= -1; diffuser.z = -Math.abs(diffuser.z)
          else if collision.dist == collision.tVals[5] then dir.z *= -1; diffuser.z =  Math.abs(diffuser.z)

          dir.add( diffuser.mult( diffuseAmount ) ).normalize()


        else
          break

      # light = if dir.y < 0 then 2 else 0.5#Math.max(-dir.y,0)*1.15
      light = r:1, g:1, b:1#@skybox.getColorForDir dir

      exposure = 1.1

      @buffer[i*3+0] += exposure * ray.color.r * (ray.light.r + light.r)
      @buffer[i*3+1] += exposure * ray.color.g * (ray.light.g + light.g)
      @buffer[i*3+2] += exposure * ray.color.b * (ray.light.b + light.b)

      # to show density of bounces
      # @buffer[i*3+0] += bounce / @maxBounces
      # @buffer[i*3+1] += bounce / @maxBounces
      # @buffer[i*3+2] += bounce / @maxBounces
      

    @updateImageData()

    @endTime = new Date

    @updateStats()


    document.body.appendChild @canvas




renderer = new Renderer
renderer.scene = new TestScene

tick = ->
  renderer.doPass()
  requestAnimationFrame tick

tick()