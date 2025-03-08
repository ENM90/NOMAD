# crouching_state.gd
extends "state-machine.gd"

func enter() -> void:
	player.current_speed = player.crouching_speed
	player.head.position.y = player.crouching_depth
	player.standing_colission_shape.disabled = true
	player.crouching_colission_shape.disabled = false
	print("Entered CROUCHING state")

func exit() -> void:
	# Restaurar la posición original de la cámara
	player.head.position.y = 0.0
	print("Exited CROUCHING state")


func physics_update(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	if player.ray_cast_3d.is_colliding():
		if input_dir != Vector2.ZERO:
			player.direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			player.velocity.x = player.direction.x * player.current_speed
			player.velocity.z = player.direction.z * player.current_speed
		else:
			# Si no hay entrada de movimiento, desacelerar al jugador
			player.velocity.x = move_toward(player.velocity.x, 0, player.current_speed)
			player.velocity.z = move_toward(player.velocity.z, 0, player.current_speed)
		# Si hay una superficie encima, permanecer agachado
		return
	
	# Transición a WALKING
	if not Input.is_action_pressed("crouch"):
		player.standing_colission_shape.disabled = false
		player.crouching_colission_shape.disabled = true
		player.change_state(player.walking_state)

	# Lógica de movimiento
	if input_dir != Vector2.ZERO:
	
		player.direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		player.velocity.x = player.direction.x * player.current_speed
		player.velocity.z = player.direction.z * player.current_speed
	else:
		# Si no hay entrada de movimiento, desacelerar al jugador
		player.velocity.x = move_toward(player.velocity.x, 0, player.current_speed)
		player.velocity.z = move_toward(player.velocity.z, 0, player.current_speed)
