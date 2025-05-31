class_name PlayerStateMoving
extends PlayerState

func _process(_delta: float) -> void:
	if player.control_scheme == Player.ControlScheme.CPU:
		pass
	else:
		handle_human_movement()
	player.set_movement_animation()
	player.set_heading()

func handle_human_movement() -> void:
	var direction := KeyUtiles.get_input_vector(player.control_scheme)
	player.velocity = direction * player.speed

	if player.has_ball() and KeyUtiles.is_action_just_press(player.control_scheme, KeyUtiles.Action.SHOOT):
		state_transition_requested.emit(Player.State.PREPPING_SHOT)

	#if player.velocity != Vector2.ZERO and KeyUtiles.is_action_just_press(player.control_scheme, KeyUtiles.Action.SHOOT):
	#	state_transition_requested.emit(Player.State.TACKLING)
