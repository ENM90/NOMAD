# walking_state.gd
extends "state-machine.gd"

func enter() -> void:
	player.current_speed = player.walking_speed
	print("Entered WALKING state")

func physics_update(delta: float) -> void:
	# Transición a IDLE
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	if input_dir == Vector2.ZERO:
		player.change_state(player.idle_state)


	# Transición a SPRINTING
	if Input.is_action_pressed("sprint"):
		player.change_state(player.sprinting_state)

	# Transición a CROUCHING
	if Input.is_action_pressed("crouch"):
		player.change_state(player.crouching_state)

	# Lógica de movimiento
	player.direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	player.velocity.x = player.direction.x * player.current_speed
	player.velocity.z = player.direction.z * player.current_speed
