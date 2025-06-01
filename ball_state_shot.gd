class_name BallStateShot
extends BallState

const SHOT_DURATION := 1000
const SHOT_HEIGHT := 30.0
const SHOT_SPRITE_SCALE := 0.8

var shot_time_start := Time.get_ticks_msec()

func _enter_tree() -> void:
	set_ball_animation_from_velocity()
	sprite.scale.y = SHOT_SPRITE_SCALE
	ball.height = SHOT_HEIGHT
	shot_time_start = Time.get_ticks_msec()

func _process(delta: float) -> void:
	if Time.get_ticks_msec() - shot_time_start > SHOT_DURATION:
		state_transition_requested.emit(Ball.State.FREEFORM)
	else:
		ball.move_and_collide(ball.velocity * delta)

func _exit_tree() -> void:
	sprite.scale.y = 1.0
	#ball.height = 0
