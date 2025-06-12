class_name AIBehaviorFielder
extends AIBehavior

const PASS_PROBABILITY := 0.2
const SPREAD_ASSIST_FACTOR := 0.8
const SHOT_DISTNACE := 150
const SHOT_PROBABILITY := 30
const TACKLE_DISTANCE := 10
const TACKLE_PROBABILITY := 0.3

func perform_ai_movement() -> void:
	var total_steering_force := Vector2.ZERO
	if player.has_ball():
		total_steering_force += get_carrier_steering_force()
	elif is_ball_carried_by_teammate():
		total_steering_force += get_assist_formation_steering_force()
	else:
		total_steering_force += get_on_duty_steering_force()
		if total_steering_force.length_squared() < 1:
			if is_ball_possessed_by_opponents():
				total_steering_force += get_spawn_steering_force()
			elif ball.carrier == null:
				total_steering_force += get_ball_proximity_steering_force()

	total_steering_force = total_steering_force.limit_length(1.0)
	player.velocity = total_steering_force * player.speed

func perform_ai_decisions() -> void:
	if is_ball_possessed_by_opponents() \
	and player.position.distance_to(ball.carrier.position) < TACKLE_DISTANCE and randf() < TACKLE_PROBABILITY:
		player.switch_states(Player.State.TACKLING)
	if ball.carrier == player:
		var target := player.target_goal.get_center_target_position()
		if player.position.distance_to(target) < SHOT_DISTNACE and randf() < SHOT_PROBABILITY:
			face_towards_target_goal()
			var shot_direction := player.position.direction_to(player.target_goal.get_random_target_position())
			var data := PlayerStateData.build().set_shot_power(player.power).set_shot_direction(shot_direction)
			player.switch_states(Player.State.SHOOTING, data)
		elif randf() < PASS_PROBABILITY and has_opponents_nearby() and has_teammate_in_view():
			player.switch_states(Player.State.PASSING)

func get_on_duty_steering_force() -> Vector2:
	return player.weight_on_duty_steering * player.position.direction_to(ball.position)

func get_carrier_steering_force() -> Vector2:
	var target := player.target_goal.get_center_target_position()
	var direction := player.position.direction_to(target)
	var weight := get_bicircular_weight(player.position, target, 100, 0, 150, 1)
	return weight * direction

func get_bicircular_weight(position: Vector2, center_target: Vector2, inner_circle_radius: float,
						   inner_circle_weight: float, outer_circle_radius: float,
						   outer_circle_weight: float) -> float:
	var distance_to_center := position.distance_to(center_target)
	if distance_to_center > outer_circle_radius:
		return outer_circle_weight
	elif distance_to_center < inner_circle_radius:
		return inner_circle_weight
	else:
		var distance_to_inner_radius := distance_to_center - inner_circle_radius
		var close_range_distance := outer_circle_radius - inner_circle_radius
		return lerpf(inner_circle_weight, outer_circle_weight, distance_to_inner_radius / close_range_distance)

func get_assist_formation_steering_force() -> Vector2:
	var spawn_difference := ball.carrier.spawn_position - player.spawn_position
	var assist_destination := ball.carrier.position - spawn_difference * SPREAD_ASSIST_FACTOR
	var direction := player.position.direction_to(assist_destination)
	var weight := get_bicircular_weight(player.position, assist_destination, 30, 0.2, 60, 1)
	return weight * direction

func get_ball_proximity_steering_force() -> Vector2:
	var weight := get_bicircular_weight(player.position, ball.position, 50, 1, 120, 0)
	var direction := player.position.direction_to(ball.position)
	return weight * direction

func get_spawn_steering_force() -> Vector2:
	var weight := get_bicircular_weight(player.position, player.spawn_position, 30, 0, 100, 1)
	var direction := player.position.direction_to(player.spawn_position)
	return weight * direction

func has_teammate_in_view() -> bool:
	var players_in_view := teammate_detection_area.get_overlapping_bodies()
	return players_in_view.find_custom(func(p: Player): return p != player and p.country == player.country) > -1
