extends "state-machine.gd"

func enter() -> void:
	player.current_speed = 0.0
	print("Entered IDLE state")

func physics_update(delta: float) -> void:
	# Transición a WALKING
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	if input_dir != Vector2.ZERO:
		player.change_state(player.walking_state)

	# Transición a CROUCHING
	if Input.is_action_pressed("crouch"):
		player.change_state(player.crouching_state)
