extends KinematicBody2D

var moveSpeed : int = 200
var vel : Vector2 = Vector2()
var direction : Vector2 = Vector2()

func _ready():
	pass # Replace with function body.

func _physics_process (delta):
	vel = Vector2()
	
	#inputs
	if Input.is_action_pressed("move_up"):
		vel.y -= 1
		direction = Vector2(0,-1)
	if Input.is_action_pressed("move_down"):
		vel.y += 1
		direction = Vector2(0,1)
	if Input.is_action_pressed("move_left"):
		vel.x -= 1
		direction = Vector2(-1,0)
	if Input.is_action_pressed("move_right"):
		vel.x += 1
		direction = Vector2(1,0)
		
	vel = vel.normalized()
	
	move_and_slide(vel * moveSpeed)
