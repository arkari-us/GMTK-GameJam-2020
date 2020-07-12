extends KinematicBody2D

var health : int = 10
var moveSpeed = 30
var attackSpeed : float = 0.5
var attackDamage : int = 10
var vel : Vector2 = Vector2()
var attackMove : int = 0
var knockback_direction : Vector2 = Vector2()
var knockbackSpeed = 50
var attackDist : int = 20
var chaseDist : int = 400

onready var anim : AnimatedSprite = get_node("HyenaSprite")
onready var target = get_node("/root/Main/Player")
onready var attackTimer = get_node("AttackTimer")
onready var attackAnimTimer = get_node("AttackAnimTimer")
onready var knockBackTimer = get_node("KnockBackTimer")

func _ready():
	attackTimer.wait_time = attackSpeed
	
func _physics_process(delta):
	
	var dist = position.distance_to(target.position)
	
	if dist > attackDist and dist < chaseDist:
		
		vel = (target.position - position).normalized()
		
		move_and_slide(vel * moveSpeed)
	
	if vel.x != 0:
		anim.flip_h = vel.x > 0
		
	manage_animations()
	attack()

func manage_animations():
	if !attackAnimTimer.is_stopped():
		play_animation("HyenaAttack")
	elif vel.x == 0 and vel.y == 0 and attackAnimTimer.is_stopped():
		play_animation("HyenaIdle")
	elif vel.x != 0 or vel.y != 0 and attackAnimTimer.is_stopped():
		play_animation("HyenaMove")
	
		
func play_animation(anim_name):
	if anim.animation != anim.name:
		anim.play(anim_name)
		

func attack():
	if position.distance_to(target.position) <= attackDist and attackTimer.is_stopped():
		attackTimer.start(attackSpeed)
		attackAnimTimer.start(attackSpeed / 3)
	else:
		attackTimer.stop()
		attackAnimTimer.stop()
