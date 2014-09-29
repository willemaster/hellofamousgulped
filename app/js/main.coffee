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



class BubbleBox extends View
  DEFAULT_OPTIONS:
    numBodies: 8
    primaryForce: [0.00001, 0, 0]
    size: [500, 500]
    origin: [0, 0]

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
    @bubbleBodies = []
    GenericSync.register
      'mouse': MouseSync
      'touch': TouchSync


  addBubble: (i) =>
    bubble = new Bubble()
    @pe.addBody bubble.body
    bubble.state.transformFrom =>
      @primaryForce.applyForce bubble.body
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

  addBubbles: ->
    [0...@options.numBodies].map (i) =>
      Timer.setTimeout (@addBubble.bind @, i), 1000

class Bubble
  constructor: ->
    radius = Random.integer 20, 60
    @shape = new ImageSurface
      size: [radius * 2, radius * 2]
      classes: ['bubble-bluebubble']
      properties: borderRadius: "#{radius}px"
    @shape.setContent("img/face1.png")
    @body = new Circle radius: radius, mass: 1, velocity: [0.1, 0.1, 0]
    @state = new Modifier origin: [0, 0]


mainCtx = Engine.createContext()
appView = new BubbleBox()
mainCtx.add appView
appView.addBubbles()