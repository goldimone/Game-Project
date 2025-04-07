extends CharacterBody3D

signal coin_collected
signal donut_collected

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed = 350	
@export var jump_strength = 12

var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0

var previously_floored = false

var jump_single = true
var jump_double = true

var coins = 0
var donuts = 0
var health = 100
var game_over_play_count = 0


@onready var model = $Character
@onready var animation = $Character/AnimationPlayer
@onready var gun1 = $RayCast3D
@onready var gun2 = $RayCast3D2
@onready var coin_ping = $Coin
@onready var donut_ping = $Donut
@onready var game_over_ping = $GameOver
@onready var background = $"../BG_Music"
@onready var jump_ping = $Jump

#Bullets
var bullets = load("res://objects/bullet.tscn")
var instance1 
var instance2

# Functions

func _ready() -> void:
	Global.set("player", self)

func _process(delta: float) -> void:
	if health <= 0:
		game_over()
		
func game_over():
	background.stop()
	
	if !game_over_ping.is_playing() && game_over_play_count == 0:
		game_over_ping.play()
		game_over_play_count += 1
	elif !game_over_ping.is_playing():
		game_over_play_count = 0
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	# Handle effects
	handle_controls(delta)
	handle_effects(delta)
	handle_gravity(delta)
	
	# Add the movement
	var applied_velocity: Vector3

	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity

	velocity = applied_velocity

	move_and_slide()
	
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()

	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)

	# Falling/respawning

	if position.y < -10:
		get_tree().reload_current_scene()

	previously_floored = is_on_floor()

# Handle animation(s)

func handle_effects(delta):
	if is_on_floor():
		var horizontal_velocity = Vector2(velocity.x, velocity.z)
		var speed_factor = horizontal_velocity.length() / movement_speed / delta
		if speed_factor > 0.05:
			if animation.current_animation != "RobotArmature|Walk":
				animation.play("RobotArmature|Walk", 0.1)
		elif animation.current_animation != "RobotArmature|Walk":
			animation.play("RobotArmature|Idle")
		elif Input.is_action_pressed("jump"):
			animation.play("RobotArmature|Jump",0.1)
	elif animation.current_animation != "RobotArmature|Jump":
		animation.play("RobotArmature|Jump", 0.1)	
# Handle movement input

func handle_controls(delta):
	# Movement

	var input := Vector3.ZERO
	var speed = 0.1

	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	
	input = input.rotated(Vector3.UP, view.rotation.y)

	if input.length() > 1:
		input = input.normalized()
		
	movement_velocity = input * movement_speed * delta

	# Jumping		
	if Input.is_action_just_released("jump"):
		if jump_single or jump_double:
			jump()
			jump_ping.play()
	
	if Input.is_action_just_pressed("shoot"):
		Audio.play("res://audio/attack.mp3")
		shoots()
	
# Handle gravity

func handle_gravity(delta):

	gravity += 25 * delta

	if gravity > 0 and is_on_floor():
		jump_single = true
		gravity = 0

# Jumping

func jump():
	gravity = -jump_strength

	if jump_single:
		jump_single = false;
		jump_double = true;
	else:
		jump_double = false;

func shoots():
	if animation.current_animation != "RobotArmature|Shoot_Small":
		animation.play("RobotArmature|Shoot_Small",0.1)
		instance1 = bullets.instantiate()
		instance2 = bullets.instantiate()
		instance1.position = gun1.global_position
		instance2.position = gun2.global_position
		instance1.transform.basis = gun1.global_transform.basis
		instance2.transform.basis = gun2.global_transform.basis
		get_parent().add_child(instance1)
		get_parent().add_child(instance2)
	
# Collecting coins

func collect_coin():
	coins += 1
	coin_ping.play()
	coin_collected.emit(coins)
	
func collect_donut():
	donuts += 1
	if health < 91:
		health += 10
	else:
		health = 100
	donut_collected.emit(donuts)

func _on_coin_body_entered(body: Node3D) -> void:
	pass

func _on_donut_body_entered(body: Node3D) -> void:
	pass # Replace with function body.


func _on_hitbox_body_entered(body: Node3D) -> void:
	pass # Replace with function body.

func _on_hitbox_large_body_entered(body: Node3D) -> void:
	pass # Replace with function body.


func _on_hitbox_large_body_exited(body: Node3D) -> void:
	pass # Replace with function body.


func _on_hitbox_body_exited(body: Node3D) -> void:
	pass # Replace with function body.
