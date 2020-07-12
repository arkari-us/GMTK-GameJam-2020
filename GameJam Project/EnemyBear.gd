extends KinematicBody2D

var health : int = 20
var moveSpeed = 20
var attackSpeed : float = 1
var attackDamage : int = 10
var vel : Vector2 = Vector2()
var attackMove : int = 10
var knockback_direction : Vector2 = Vector2()
var attack_dir : Vector2 = Vector2()
var knockbackSpeed = 50
var knockbackTime = .5
var attackDist : int = 20
var chaseDist : int = 400
var rayCastScale : Vector2 = Vector2(20,1)
var attacked = false

onready var anim : AnimatedSprite = get_node("BearSprite")
onready var target = get_node("/root/Main/Player")
onready var attackTimer = get_node("AttackTimer")
onready var attackAnimTimer = get_node("AttackAnimTimer")
onready var knockBackTimer = get_node("KnockBackTimer")
onready var rayCast = get_node("RayCast2D")

func _ready():
	attackTimer.wait_time = attackSpeed
	rayCast.scale = rayCastScale
	
func _physics_process(delta):
	
	var dist = position.distance_to(target.position)
	
	if !knockBackTimer.is_stopped():
		vel = ((position - knockback_direction)*2).normalized()
		move_and_slide(vel * knockbackSpeed)
	elif dist > attackDist and dist < chaseDist:
		
		vel = (target.position - position).normalized()
		
		move_and_slide(vel * moveSpeed)
	
	if vel.x != 0:
		anim.flip_h = vel.x > 0
		
	manage_animations()
	attack()

func manage_animations():
	if !attackAnimTimer.is_stopped():
		play_animation("BearAttack")
	elif !knockBackTimer.is_stopped():
		play_animation("BearIdle")
	elif vel.x == 0 and vel.y == 0 and attackAnimTimer.is_stopped():
		play_animation("BearIdle")
	elif vel.x != 0 or vel.y != 0 and attackAnimTimer.is_stopped():
		play_animation("BearMove")

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

func dealDamage():
	if !attacked:
		target.takeDamage(attackDamage,position)
		attacked = true;

func takeDamage(dmg, dir):
	knockback_direction = dir
	health -= (dmg)
	knockBackTimer.start(knockbackTime)
	attackTimer.stop()
	attackAnimTimer.stop()

func _on_AttackTimer_timeout():
	attacked = false;
