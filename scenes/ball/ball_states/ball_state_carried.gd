class_name BallStateCarried
extends BallState


const OFFSET_FROM_PLAYER := Vector2(10, 4)

var carry_time := 0.0
const DRIBBLE_SPEED := 10.0
const DRIBBLE_MAGNITUDE := 2
const DRIBBLE_OFFSET := 2

func _enter_tree() -> void:
	assert(carrier != null)

func _process(delta: float) -> void:
	var extra_x = 0
	var extra_y = 0
	carry_time += delta

	if carrier.velocity != Vector2.ZERO:
		if carrier.velocity.x != 0:
			extra_x = (sin(carry_time * DRIBBLE_SPEED) * DRIBBLE_MAGNITUDE) + DRIBBLE_OFFSET
		if carrier.velocity.y != 0:
			extra_y = (sin(carry_time * DRIBBLE_SPEED) * DRIBBLE_MAGNITUDE) + DRIBBLE_OFFSET
			if carrier.velocity.y < 0:
				extra_y = -extra_y - 2

		if carrier.heading.x >= 0:
			animation_player.play('roll')
			animation_player.advance(0)
		else:
			extra_x = -extra_x
			animation_player.play_backwards('roll')
			animation_player.advance(0)
		

	else:
		animation_player.play('idle')
	var offset_position = Vector2(carrier.heading.x * OFFSET_FROM_PLAYER.x, OFFSET_FROM_PLAYER.y)
	var extra_offset = Vector2(extra_x, extra_y).normalized() * max(abs(extra_x), abs(extra_y))
	ball.position = carrier.position + offset_position + extra_offset
