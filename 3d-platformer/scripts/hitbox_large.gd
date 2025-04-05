extends Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_body_entered(body):
	if body.has_method("collect_coin"):
		$Timer.start()

func _on_body_exited(body):
	if body.has_method("collect_coin"):
		$Timer.stop()

func _on_timer_timeout():
	Global.player.health -= 25
	print("health: ", Global.player.health)
