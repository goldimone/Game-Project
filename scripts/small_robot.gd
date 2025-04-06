extends CharacterBody3D

var speed = 3
var walking_distance = 2
var start_position = 8
var direction = 1
var current_dir

var walking = false
var attacking = false

@onready var animation = $Enemy/AnimationPlayer

func ready():
	start_position = position.x

func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta
	
	if (position.x >= start_position + walking_distance):
		walking = true
		direction = -1
		current_dir = -1
	if (position.x <= start_position - walking_distance):
		walking = true
		direction = 1
		current_dir = 1
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is CharacterBody3D:
			walking = false
			attacking = true
		
	
func _process(delta):
	if walking == true && attacking == false:
		animation.play("CharacterArmature|Walk", 0.1)
	elif walking == false && attacking == true:
		direction = 0
		animation.play("CharacterArmature|Attack", 0.1)
		await get_tree().create_timer(1.0).timeout
		direction = current_dir
		walking = true
		attacking = false


func _on_hitbox_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
