extends KinematicBody2D

enum {ANIMAL_BEAR, ANIMAL_HYENA, ANIMAL_RABBIT}

var vel : Vector2 = Vector2()
var direction : Vector2 = Vector2()
var knockback_direction : Vector2 = Vector2()
var knockbackSpeed = 50
var iframeTime = 1
var singleTargetHit = false
var attack_dir : Vector2 = Vector2()
var rayCastExceptions : Array = []

var transformTime_min = 3
var transformTime_max = 7

var health = 100

var animals = [
	{
		animal = ANIMAL_BEAR,
		name = "Bear",
		attackSpeed = 1,
		attackDamage = 5,
		attackMove = 10,
		moveSpeed = 30,
		armor = 2,
		superArmor = true,
		scale = Vector2(2,3),
		rayCastScale = Vector2(20,1),
		frames = preload("res://BearAnim.tres"),
		singleTarget = false
	},
	{
		animal = ANIMAL_HYENA,
		name = "Hyena",
		attackSpeed = 1,
		attackDamage = 10,
		attackMove = 0,
		moveSpeed = 50,
		armor = 1,
		superArmor = false,
		scale = Vector2(1.552, 1.495),
		rayCastScale = Vector2(15,1),
		frames = preload("res://HyenaAnim.tres"),
		singleTarget = true
	},
	{
		animal = ANIMAL_RABBIT,
		name = "Rabbit",
		attackSpeed = 2.5,
		attackDamage = 2,
		attackMove = 350,
		moveSpeed = 75,
		armor = 0,
		superArmor = false,
		scale = Vector2(0.582, 0.432),
		rayCastScale = Vector2(15,1),
		frames = preload("res://RabbitAnim.tres"),
		singleTarget = false
	}
]

var currentAnimal = null
var rng = RandomNumberGenerator.new()

onready var transformTimer = get_node("TransformTimer")
onready var attackTimer = get_node("AttackTimer")
onready var attackAnimTimer = get_node("AttackAnimTimer")
onready var knockBackTimer = get_node("KnockBackTimer")
onready var iFrameTimer = get_node("IFrameTimer")
onready var tformAnimTimer = get_node("TransformAnimTimer")

onready var rayCast = get_node("RayCast2D")
onready var anim : AnimatedSprite = get_node("PlayerSprite")

func _ready():
	var i = rng.randi() % (animals.size()-1)
	currentAnimal = clone_dictionary(animals[i])
	animals.remove(i)
	transformTimer.start(rng.randi_range(transformTime_min, transformTime_max))
	anim.set_sprite_frames(currentAnimal.frames)
	anim.set_scale(currentAnimal.scale)
	rayCast.scale = currentAnimal.rayCastScale

func _physics_process (_delta):
	vel = Vector2()
	
	#inputs
	if !knockBackTimer.is_stopped():
		move_and_slide(knockback_direction.normalized() * knockbackSpeed)
	elif !attackAnimTimer.is_stopped():
		vel = (get_global_mouse_position() - position).normalized()
		if position.distance_to(get_global_mouse_position()) > 5:
			move_and_slide(vel * currentAnimal.attackMove)
		rayCast.cast_to = vel
		dealDamage()
	else:
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
		if Input.is_action_pressed("attack"):
			attack()
		move_and_slide(vel.normalized() * currentAnimal.moveSpeed)
		
	if vel.x != 0:
		anim.flip_h = vel.x > 0
		
	manage_animations()

func attack():
	if attackTimer.is_stopped():
		attackTimer.start(currentAnimal.attackSpeed)
		attackAnimTimer.start(currentAnimal.attackSpeed / 5)
		attack_dir = (get_global_mouse_position() - position).normalized()
		
func take_damage(dmg,dir):
	if !iFrameTimer.is_stopped():
		health -= dmg
		knockBackTimer.start(.15)
		knockback_direction = dir
		iFrameTimer.start(iframeTime)

func _on_TransformTimer_timeout():
	var i = rng.randi_range(0,animals.size()-1)
	var temp = clone_dictionary(animals[i])
	animals.remove(i)
	animals.push_back(clone_dictionary(currentAnimal))
	currentAnimal = clone_dictionary(temp)
	transformTimer.start(rng.randi_range(transformTime_min, transformTime_max))
	tformAnimTimer.start(.25)
	tform()

func _on_KnockBackTimer_timeout():
	knockback_direction = Vector2()

func clone_dictionary(dict):
	var newDict = {}
	for key in dict:
		newDict[key] = dict[key]
	return newDict
	
#func _process(delta):
#	if Input.is_action_just_pressed("transform"):
#		transformTimer.start(.2)
#		tform()
		
func manage_animations():
	if !tformAnimTimer.is_stopped():
		play_animation("Transform")
	elif !attackAnimTimer.is_stopped():
		play_animation(currentAnimal.name + "Attack")
	elif vel.x == 0 and vel.y == 0 and attackAnimTimer.is_stopped():
		play_animation(currentAnimal.name + "Idle")
	elif vel.x != 0 or vel.y != 0 and attackAnimTimer.is_stopped():
		play_animation(currentAnimal.name + "Move")

func play_animation(anim_name):
	if anim.animation != anim.name:
		anim.play(anim_name)

func tform():
	anim.set_sprite_frames(currentAnimal.frames)
	anim.set_scale(currentAnimal.scale)
	rayCast.scale = currentAnimal.rayCastScale

func _on_AttackAnimTimer_timeout():
	attack_cleanup()

func dealDamage():
	if currentAnimal.singleTarget:
		if !singleTargetHit and rayCast.is_colliding():
			var e = rayCast.get_collider()
			e.takeDamage(currentAnimal.attackDamage,position)
			singleTargetHit = true
	else:
		while rayCast.is_colliding():
			var e = rayCast.get_collider()
			rayCastExceptions.append(e)
			rayCast.add_exception(e)
			rayCast.force_raycast_update()
			e.takeDamage(currentAnimal.attackDamage,position)

func takeDamage(dmg, dir):
	if iFrameTimer.is_stopped():
		knockback_direction = dir
		health -= dmg
		knockBackTimer.start(knockbackSpeed)
		iFrameTimer.start(iframeTime)
		attackTimer.stop()
		attackAnimTimer.stop()
		attack_cleanup()
		
		
func attack_cleanup():
	for e in rayCastExceptions:
		rayCast.remove_exception(e)
	rayCastExceptions = []
	singleTargetHit = false
