extends CharacterBody3D

var speed = 3
var idle = false
var attacking = false

@onready var animation = $Enemy/AnimationPlayer

func ready():
	pass

func _physics_process(delta: float) -> void:
	move_and_slide()
	idle = true
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is CharacterBody3D:
			idle = false
			attacking = true

func _process(delta):
	if idle == true && attacking == false:
		animation.play("CharacterArmature|Idle", 0.1)
	elif idle == false && attacking == true:
		animation.play("CharacterArmature|Attack", 0.1)
		await get_tree().create_timer(1.0).timeout
		idle = true
		attacking = false
