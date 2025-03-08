# sliding_state.gd
extends "state-machine.gd"

func enter() -> void:
	player.sliding = true
	player.slide_timer = player.slide_timer_max
	player.slide_vector = Input.get_vector("left", "right", "forward", "backward")
	print("Entered SLIDING state")

func physics_update(delta: float) -> void:
	# Reducir el temporizador de deslizamiento
	player.slide_timer -= delta

	# Transición a CROUCHING
	if player.slide_timer <= 0:
		player.sliding = false
		player.change_state(player.crouching_state)

	# Lógica de movimiento
	player.direction = (player.transform.basis * Vector3(player.slide_vector.x, 0, player.slide_vector.y)).normalized()
	player.velocity.x = player.direction.x * player.slide_speed
	player.velocity.z = player.direction.z * player.slide_speed
