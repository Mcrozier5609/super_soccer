class_name AIBehavior
extends Node

const DURATION_AI_TICK_FREQUENCY := 200

var ball : Ball = null
var opponent_detection_area : Area2D = null
var player : Player = null
var teammate_detection_area : Area2D = null
var time_since_last_ai_tick := Time.get_ticks_msec()

func _ready() -> void:
	time_since_last_ai_tick = Time.get_ticks_msec()  + randi_range(0, DURATION_AI_TICK_FREQUENCY)

func setup(context_player : Player, context_ball: Ball, context_opponent_detection_area: Area2D,
		   context_teammate_detection_area: Area2D) -> void:
	player = context_player
	ball = context_ball
	opponent_detection_area = context_opponent_detection_area
	teammate_detection_area = context_teammate_detection_area

func process_ai() -> void:
	if Time.get_ticks_msec() - time_since_last_ai_tick > DURATION_AI_TICK_FREQUENCY:
		time_since_last_ai_tick = Time.get_ticks_msec()
		perform_ai_movement()
		perform_ai_decisions()

func perform_ai_movement() -> void:
	pass

func perform_ai_decisions() -> void:
	pass

func is_ball_carried_by_teammate() -> bool:
	return ball.carrier != null and ball.carrier != player and ball.carrier.country == player.country

func is_ball_possessed_by_opponents() -> bool:
	return ball.carrier != null and ball.carrier.country != player.country

func has_opponents_nearby() -> bool:
	var players := opponent_detection_area.get_overlapping_bodies()
	return players.find_custom(func(p: Player): return p.country != player.country) > -1
