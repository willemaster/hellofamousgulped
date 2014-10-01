'use strict'

# Use Famo.us polyfills: Universal access to CSS3 transforms
require 'famous-polyfills/index'

# Get nice colors
require 'colors/coffee/colors'

# Require Famo.us libraries
Engine = require 'famous/core/Engine'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
View = require 'famous/core/View'
Modifier = require 'famous/core/Modifier'
Force = require 'famous/physics/forces/Force'
RotationalSpring = require 'famous/physics/forces/RotationalSpring'
Walls = require 'famous/physics/constraints/Walls'
PhysicsEngine = require 'famous/physics/PhysicsEngine'
Collision = require 'famous/physics/constraints/Collision'
GenericSync = require 'famous/inputs/GenericSync'
MouseSync = require 'famous/inputs/MouseSync'
TouchSync = require 'famous/inputs/TouchSync'
Circle = require 'famous/physics/bodies/Circle'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'
Random = require 'famous/math/Random'
Vector = require 'famous/math/Vector'



class BubbleBox extends View
  DEFAULT_OPTIONS:
    numBodies: 8
    primaryForce: [0.000001, 0.000001, 0]
    size: [700, 700]
    origin: [0.5, 0.5]

  constructor: (@options)->
    @constructor.DEFAULT_OPTIONS = @DEFAULT_OPTIONS
    super @options
    surf = new Surface
      size: @options.size
      classes: ['bubble-main-box']
    mod = new Modifier origin: @options.origin
    @add(mod).add surf
    @primaryForce = new Force @options.primaryForce
    @walls = new Walls
      size: @options.size
      origin: @options.origin
    @pe = new PhysicsEngine()
    #@collision = new Collision restitution: 0
    @bubbles = []
    @bubbleBodies = []
    GenericSync.register
      'mouse': MouseSync
      'touch': TouchSync

  addBubble: (i) =>
    bubble = new Bubble(i)
    @pe.addBody bubble.body
    @mainForce = new Force [0, -0.00001, 0]
    @mainForce.setEnergy 10
    bubble.state.transformFrom =>
      @mainForce.applyForce bubble.body
      bubble.body.getTransform()
    (@add bubble.state).add bubble.shape
    @pe.attach [
      @walls.components[0]
      @walls.components[1]
      @walls.components[2]
      @walls.components[3]
    ] , bubble.body
    #(@pe.attach @collision, @bubbleBodies, bubble.body) if i > 0
    #@pe.attach @collision, [bubble.body], @dragger.body
    @bubbleBodies.push bubble.body
    @bubbles.push bubble
  
  updateBubble: (i) =>
    @bubbles[i].update()

  addBubbles: ->
    [0...@options.numBodies].map (i) =>
      Timer.setTimeout (@addBubble.bind @, i), 1000

  updateBubbles: ->
    [0...@options.numBodies].map (i) =>
      Timer.setTimeout (@updateBubble.bind @, i), 4000

class Bubble
  constructor: (id) ->
    @id = id
    radius = Random.integer 20, 60
    @shape = new ImageSurface
      size: [radius * 2, radius * 2]
      classes: ['bubble-bluebubble']
      properties: borderRadius: "#{radius}px"
    @shape.setContent("img/face1.png")
    @shape.on("click", ->
        alert @id
    )
    @body = new Circle radius: radius, mass: 1, velocity: [0.1, 0, 0]
    @state = new Modifier origin: [(Random.integer -1, 1), (Random.integer -1, 1)]
  update: ->
    @state.transformFrom =>
      # (new Force [(Random.integer -1, 1) * 0.0001, (Random.integer -1, 1) * 0.0001, 0]).applyForce @body
      @body.getTransform()

mainCtx = Engine.createContext()
appView = new BubbleBox()
mainCtx.add appView
appView.addBubbles()
# appView.updateBubbles()
