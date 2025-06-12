class_name PlayerStatePreppingShot
extends PlayerState

const DURATION_MAX_BONUS := 1000.0
const EASE_REWARD_FACTOR := 2.0

var initial_shot_direction := Vector2.ZERO
var shot_direction := Vector2.ZERO
var time_start_shot := Time.get_ticks_msec()

func _enter_tree() -> void:
	animation_player.play('prep_kick')
	player.velocity = Vector2.ZERO
	time_start_shot = Time.get_ticks_msec()
	initial_shot_direction = player.heading

func _process(delta: float) -> void:
	shot_direction += KeyUtiles.get_input_vector(player.control_scheme) * delta
	if KeyUtiles.is_action_just_released(player.control_scheme, KeyUtiles.Action.SHOOT):
		var duration_press = clampf(Time.get_ticks_msec() - time_start_shot, 0.0, DURATION_MAX_BONUS)
		var ease_time = duration_press / DURATION_MAX_BONUS
		var bonus := ease(ease_time, EASE_REWARD_FACTOR)
		var shot_power = player.power * (1 + bonus)
		if shot_direction == Vector2.ZERO:
			shot_direction = initial_shot_direction
		shot_direction = shot_direction.normalized()
		var data = PlayerStateData.build().set_shot_power(shot_power).set_shot_direction(shot_direction)
		transition_state(Player.State.SHOOTING, data)

func can_pass() -> bool:
	return true
