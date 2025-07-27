class_name ActorsContainer
extends Node2D

const DURATION_WEIGHT_CACHE := 200
const PLAYER_PREFAB := preload("res://scenes/characters/player.tscn")
const SPARK_PREFAB := preload("res://scenes/spark/spark.tscn")

@export var ball: Ball
@export var goal_home: Goal
@export var goal_away: Goal

@onready var kickoffs : Node2D = %KickOffs
@onready var spawns : Node2D = %Spawns
@onready var top_crowd : Sprite2D = %TopCrowd

var is_checking_for_kickoff_readiness := false
var squad_home : Array[Player] = []
var squad_away : Array[Player] = []
var time_since_last_cache_refresh := Time.get_ticks_msec()

# Crowd stuff
var crowd_texture_1 = preload("res://assets/art/backgrounds/crowd_1.png")
var crowd_texture_2 = preload("res://assets/art/backgrounds/crowd_2.png")
var crowd_texture_3 = preload("res://assets/art/backgrounds/crowd_3.png")
var crowd_list : Array = [crowd_texture_1, crowd_texture_2, crowd_texture_3]
var current_crowd := 0
var time_at_sprite_swap := Time.get_ticks_msec()
var time_at_tackle := Time.get_ticks_msec()
var tackled := false
var scored := false
var crowd_noise_lvl := 1.0

const MIN_SPRITE_DWELL_TIME := 100.0
const MAX_SPRITE_DWELL_TIME := 500.0
const TACKLE_CELEBRATION_TIME := 1000.0
const TACKLE_SPRITE_DWELL_TIME := 50.0
const MIN_CROWD_NOISE := 0.5
const MAX_CROWD_NOISE := 1.5
const TACKLE_CROWD_NOISE := 4.0

func _init() -> void:
	GameEvents.team_reset.connect(on_team_reset.bind())
	GameEvents.impact_received.connect(on_impact_received.bind())
	GameEvents.team_scored.connect(on_team_scored_on.bind())

func _ready() -> void:
	squad_home = spawn_players(GameManager.current_matchup.country_home, goal_home)
	goal_home.initialize(GameManager.current_matchup.country_home)
	spawns.scale.x = -1
	kickoffs.scale.x = -1
	squad_away = spawn_players(GameManager.current_matchup.country_away, goal_away)
	goal_away.initialize(GameManager.current_matchup.country_away)
	setup_control_schemes()
	set_crowd_shader_properties()

func _process(delta: float) -> void:
	if Time.get_ticks_msec() - time_since_last_cache_refresh > DURATION_WEIGHT_CACHE:
		time_since_last_cache_refresh = Time.get_ticks_msec()
		set_on_duty_weights()
	if is_checking_for_kickoff_readiness:
		check_for_kickoff_readiness()
	# crowd stuff
	var sprite_dwell_time := 100.0
	if tackled:
		sprite_dwell_time = TACKLE_SPRITE_DWELL_TIME
		SoundPlayer.play(SoundPlayer.Sound.CROWD_WOOSH, 0.5)
		if Time.get_ticks_msec() - time_at_tackle > TACKLE_CELEBRATION_TIME:
			tackled = false
	if scored:
		crowd_noise_lvl = TACKLE_CROWD_NOISE
		if Time.get_ticks_msec() - time_at_tackle > TACKLE_CELEBRATION_TIME:
			scored = false
	else:
		var goal_position := 0.0
		var center_offset := 0.0
		var clmp_x_position := 0.0
		if ball.position[0] > ball.spawn_position[0] + 30:
			center_offset = ball.spawn_position[0] + 30
			goal_position = goal_away.position[0] - 100
			clmp_x_position = clampf(ball.position[0], center_offset, goal_position)
		else:
			center_offset = ball.spawn_position[0] - 30
			goal_position = goal_home.position[0] + 100
			clmp_x_position = clampf(ball.position[0], goal_position, center_offset)
		var distance_weight : float = abs(clmp_x_position - goal_position) / abs(center_offset - goal_position)
		sprite_dwell_time = (distance_weight * (MAX_SPRITE_DWELL_TIME - MIN_SPRITE_DWELL_TIME) + MIN_SPRITE_DWELL_TIME)
		crowd_noise_lvl = ((1 - distance_weight) * (MAX_CROWD_NOISE - MIN_CROWD_NOISE) + MIN_CROWD_NOISE)
		crowd_noise_lvl = SoundPlayer.smooth_sound(delta, crowd_noise_lvl)
		
	if Time.get_ticks_msec() - time_at_sprite_swap > sprite_dwell_time:
		time_at_sprite_swap = Time.get_ticks_msec()
		current_crowd += 1
		if current_crowd == 3:
			current_crowd = 0
		top_crowd.texture = crowd_list[current_crowd]
	SoundPlayer.crowd_player.set_volume_linear(crowd_noise_lvl)

func spawn_players(country: String, own_goal: Goal) -> Array[Player]:
	var player_nodes : Array[Player] = []
	var players := DataLoader.get_squad(country)
	var target_goal := goal_home if own_goal == goal_away else goal_away
	for i in players.size():
		var player_position := spawns.get_child(i).global_position as Vector2
		var player_data := players[i] as PlayerResource
		var kickoff_position := player_position
		if i > 3:
			kickoff_position = kickoffs.get_child(i - 4).global_position as Vector2
		var player := spawn_player(player_position, own_goal, target_goal, player_data, country, kickoff_position)
		player_nodes.append(player)
		add_child(player)
	return player_nodes

func spawn_player(player_position: Vector2, own_goal: Goal, target_goal: Goal, player_data: PlayerResource,
				  country: String, kickoff_position: Vector2) -> Player:
	var player :Player = PLAYER_PREFAB.instantiate()
	player.initialize(player_position, ball, own_goal, target_goal, player_data, country, kickoff_position)
	player.swap_requested.connect(on_player_swap_request.bind())
	player.was_tackled.connect(on_tackle.bind())
	return player

func set_on_duty_weights() -> void:
	for squad in [squad_away, squad_home]:
		var cpu_players : Array[Player] = squad.filter(
			func(p: Player): return p.control_scheme == Player.ControlScheme.CPU and p.role != Player.Role.GOALIE
		)
		cpu_players.sort_custom(func(p1: Player, p2: Player):
			return p1.position.distance_squared_to(ball.position) < p2.position.distance_squared_to(ball.position))

		for i in range(cpu_players.size()):
			cpu_players[i].weight_on_duty_steering = 1 - ease(float(i)/10.0, 0.1)

func on_player_swap_request(requester: Player) -> void:
	var squad := squad_home if requester.country == squad_home[0].country else squad_away
	var cpu_players : Array[Player] = squad.filter(
			func(p: Player): return p.control_scheme == Player.ControlScheme.CPU and p.role != Player.Role.GOALIE
	)
	cpu_players.sort_custom(func(p1: Player, p2: Player):
		return p1.position.distance_squared_to(ball.position) < p2.position.distance_squared_to(ball.position))
	var closest_cpu_to_ball: Player = cpu_players[0]
	if closest_cpu_to_ball.position.distance_squared_to(ball.position) < requester.position.distance_squared_to(ball.position):
		var player_control_scheme := requester.control_scheme
		requester.set_control_scheme(Player.ControlScheme.CPU)
		closest_cpu_to_ball.set_control_scheme(player_control_scheme)

func check_for_kickoff_readiness() -> void:
	for squad in [squad_home, squad_away]:
		for player : Player in squad:
			if not player.is_ready_for_kickoff():
				return
	setup_control_schemes()
	is_checking_for_kickoff_readiness = false
	GameEvents.kickoff_ready.emit()

func setup_control_schemes() -> void:
	reset_control_schemes()
	var p1_country := GameManager.player_setup[0]
	if GameManager.is_coop():
		var player_squad := squad_home if squad_home[0].country == p1_country else squad_away
		player_squad[4].set_control_scheme(Player.ControlScheme.P1)
		player_squad[5].set_control_scheme(Player.ControlScheme.P2)
	elif GameManager.is_single_player():
		var player_squad := squad_home if squad_home[0].country == p1_country else squad_away
		player_squad[5].set_control_scheme(Player.ControlScheme.P1)
	else: # versus mode
		var p1_squad := squad_home if squad_home[0].country == p1_country else squad_away
		var p2_squad := squad_home if p1_squad == squad_away else squad_away
		p1_squad[5].set_control_scheme(Player.ControlScheme.P1)
		p2_squad[5].set_control_scheme(Player.ControlScheme.P2)

func reset_control_schemes() -> void:
	for squad in [squad_home, squad_away]:
		for player: Player in squad:
			player.set_control_scheme(Player.ControlScheme.CPU)

func on_team_reset() -> void:
	is_checking_for_kickoff_readiness = true

func on_impact_received(impact_position: Vector2, _is_high_impact: bool) -> void:
	var spark := SPARK_PREFAB.instantiate()
	spark.position = impact_position
	add_child(spark)

func set_crowd_shader_properties() -> void:
	var countries = DataLoader.get_countries()
	var home_color := countries.find(GameManager.current_matchup.country_home)
	home_color = clampi(home_color, 0, countries.size() - 1)
	top_crowd.material.set_shader_parameter("home_color", home_color)
	var away_color := countries.find(GameManager.current_matchup.country_away)
	away_color = clampi(away_color, 0, countries.size() - 1)
	top_crowd.material.set_shader_parameter("away_color", away_color)

func on_tackle() -> void:
	time_at_tackle = Time.get_ticks_msec()
	tackled = true

func on_team_scored_on(_team_scored_on: String) -> void:
	scored = true
	on_tackle()
