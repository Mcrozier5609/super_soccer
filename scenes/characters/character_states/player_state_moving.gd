class_name PlayerStateMoving
extends PlayerState

func _process(_delta: float) -> void:
	if player.control_scheme == Player.ControlScheme.CPU:
		ai_behavior.process_ai()
	else:
		handle_human_movement()
	player.set_movement_animation()
	player.set_heading()

func handle_human_movement() -> void:
	var direction := KeyUtiles.get_input_vector(player.control_scheme)
	player.velocity = direction * player.speed
	if player.velocity != Vector2.ZERO:
		teammate_detection_area.rotation = player.velocity.angle()

	if player.has_ball():
		if KeyUtiles.is_action_just_press(player.control_scheme, KeyUtiles.Action.SHOOT):
			transition_state(Player.State.PREPPING_SHOT)
		elif KeyUtiles.is_action_just_press(player.control_scheme, KeyUtiles.Action.PASS):
			transition_state(Player.State.PASSING)
	elif ball.can_air_interact() and KeyUtiles.is_action_just_press(player.control_scheme, KeyUtiles.Action.SHOOT):
		if player.velocity == Vector2.ZERO:
			if player.is_facing_target_goal():
				transition_state(Player.State.VOLLEY_KICK)
			else:
				transition_state(Player.State.BICYCLE_KICK)
		else:
			transition_state(Player.State.HEADER)

	if player.velocity != Vector2.ZERO and KeyUtiles.is_action_just_press(player.control_scheme, KeyUtiles.Action.SHOOT):
		state_transition_requested.emit(Player.State.TACKLING)
