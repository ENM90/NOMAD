# sprinting_state.gd
extends "state-machine.gd"

func enter() -> void:
	player.current_speed = player.sprinting_speed
	print("Entered SPRINTING state")

func physics_update(delta: float) -> void:
	# Transición a WALKING
	if not Input.is_action_pressed("sprint"):
		player.change_state(player.walking_state)

	# Transición a SLIDING
	if Input.is_action_pressed("crouch"):
		player.change_state(player.sliding_state)

	# Lógica de movimiento
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	player.direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	player.velocity.x = player.direction.x * player.current_speed
	player.velocity.z = player.direction.z * player.current_speed
