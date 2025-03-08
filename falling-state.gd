# falling_state.gd
extends "state-machine.gd"

func enter() -> void:
	print("Entered FALLING state")

func physics_update(delta: float) -> void:
	# Transición a WALKING
	if player.is_on_floor():
		player.change_state(player.walking_state)
