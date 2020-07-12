extends KinematicBody2D

var speed : int = 200
var currentAnimal: String = "Hyena"
var isAttacking: bool = false
var isTransforming: bool = false
onready var anim : AnimatedSprite = get_node("PlayerSprite")
onready var frames = preload("res://HyenaAnim.tres")
var vel : Vector2 = Vector2()
var rabbitScale : Vector2 = Vector2(0.582, 0.432)
var hyenaScale : Vector2 = Vector2(1.552, 1.495)
var bearScale : Vector2 = Vector2(2,3)

func _ready():
	anim.set_sprite_frames(frames)
	anim.set_scale(hyenaScale)
	
func _physics_process(delta):
	
	vel = Vector2()
	# movement inputs
	if Input.is_action_pressed("move_left"):
		vel.x -= 1
	if Input.is_action_pressed("move_right"):
		vel.x += 1
	if Input.is_action_pressed("move_up"):
		vel.y -= 1
	if Input.is_action_pressed("move_down"):
		vel.y += 1
	
	vel = vel.normalized()
	# move the player
	move_and_slide(vel * speed)
	
	
	if vel.x != 0:
		anim.flip_h = vel.x > 0
		
	manage_animations()
	
func _process(delta):
	if Input.is_action_just_pressed("transform"):
		isTransforming = true
		anim.play("Transform")
		tform()
		isTransforming = false
		
func manage_animations():
	if currentAnimal == "Hyena":
		if vel.x == 0 and vel.y == 0 and !isAttacking:
			play_animation("HyenaIdle")
		elif vel.x != 0 or vel.y != 0 and !isAttacking:
			play_animation("HyenaMove")
		elif isAttacking:
			play_animation("HyenaAttack")
		elif isTransforming:
			play_animation("Transform")
	elif currentAnimal == "Rabbit":
		if vel.x == 0 and vel.y == 0 and !isAttacking:
			play_animation("RabbitIdle")
		elif vel.x != 0 or vel.y != 0 and !isAttacking:
			play_animation("RabbitMove")
		elif isAttacking:
			play_animation("RabbitAttack")
	elif currentAnimal == "Bear":
		if vel.x == 0 and vel.y == 0 and !isAttacking:
			play_animation("BearIdle")
		elif vel.x != 0 or vel.y != 0 and !isAttacking:
			play_animation("BearMove")
		elif isAttacking:
			play_animation("BearAttack")

func play_animation(anim_name):
	if anim.animation != anim.name:
		anim.play(anim_name)
		

func tform():
	anim.play("Transform")
	if currentAnimal == "Hyena":
		currentAnimal = "Rabbit"
		frames = preload("res://RabbitAnim.tres")
		anim.set_sprite_frames(frames)
		anim.set_scale(rabbitScale)
	elif currentAnimal == "Rabbit":
		currentAnimal = "Bear"
		frames = preload("res://BearAnim.tres")
		anim.set_sprite_frames(frames)
		anim.set_scale(bearScale)
	else:
		currentAnimal = "Hyena"
		frames = preload("res://HyenaAnim.tres")
		anim.set_sprite_frames(frames)
		anim.set_scale(hyenaScale)
