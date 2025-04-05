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

@onready var model = $Character
@onready var animation = $Character/AnimationPlayer

# Functions

func _ready() -> void:
	Global.set("player", self)

func _process(delta: float) -> void:
	if health <= 0:
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
		elif Input.is_action_pressed("jump"):
			animation.play("RobotArmature|Jump",0.1)
			await get_tree().create_timer(.166).timeout
			animation.seek(.166)
			animation.pause()
		elif animation.current_animation != "RobotArmature|Idle":
			animation.play("RobotArmature|Idle", 0.1)
	elif animation.current_animation != "RobotArmature|Jump":
		animation.play("RobotArmature|Jump", 0.1,1.0,true)

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

# Collecting coins

func collect_coin():
	coins += 1
	coin_collected.emit(coins)
	
func collect_donut():
	donuts += 1
	if health < 91:
		health += 10
	else:
		health = 100
	donut_collected.emit(donuts)

func _on_coin_body_entered(body: Node3D) -> void:
	pass # Replace with function body.


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
