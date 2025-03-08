# jumping_state.gd
extends "state-machine.gd"

func enter() -> void:
	print("Entered JUMPING state")

func physics_update(delta: float) -> void:
	
	# Transición a FALLING
	if player.velocity.y <= 0:
		player.change_state(player.falling_state)
