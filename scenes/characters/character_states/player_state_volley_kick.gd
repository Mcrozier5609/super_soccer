class_name PlayerStateVolleyKick
extends PlayerState

const BALL_HEIGHT_MIN := 1.0
const BALL_HEIGHT_MAX := 20.0
const BONUS_POWER := 1.5

func _enter_tree() -> void:
	animation_player.play('volley_kick')
	ball_detection_area.body_entered.connect(on_ball_entered.bind())

func on_ball_entered(contact_ball: Ball) -> void:
	if ball.can_air_connect(BALL_HEIGHT_MIN, BALL_HEIGHT_MAX):
		var rand_direction_to_target_goal := contact_ball.position.direction_to(target_goal.get_random_target_position())
		contact_ball.shoot(rand_direction_to_target_goal * player.power * BONUS_POWER)

func on_animation_complete() -> void:
	transition_state(Player.State.RECOVERING)
