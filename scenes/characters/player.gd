class_name Player
extends CharacterBody2D

signal swap_requested(player: Player)
signal was_tackled()

const CONTROL_SCHEME_MAP : Dictionary = {
	ControlScheme.CPU: preload("res://assets/art/props/cpu.png"),
	ControlScheme.P1: preload("res://assets/art/props/1p.png"),
	ControlScheme.P2: preload("res://assets/art/props/2p.png"),
}
const GRAVITY := 8.0
const BALL_CONTROL_HEIGHT_MAX := 10.0
const WALK_ANIM_THRESHOLD := 0.6

enum ControlScheme {CPU, P1, P2}
enum Role {GOALIE, DEFENSE, MIDFIELD, OFFENSE}
enum SkinColor {LIGHT, MEDIUM, DARK}
enum State {MOVING, TACKLING, RECOVERING, PREPPING_SHOT, SHOOTING, PASSING, HEADER, VOLLEY_KICK, BICYCLE_KICK,
			CHEST_CONTROL, HURT, DIVING, CELEBRATING, MOURNING, RESETTING}

@export var ball : Ball
@export var control_scheme: ControlScheme
@export var own_goal : Goal
@export var power : float
@export var speed : float
var carry_speed : float
@export var target_goal : Goal

@onready var ball_detection_area : Area2D = %BallDetectionArea
@onready var teammate_detection_area : Area2D = %teammateDetectionArea
@onready var animation_player : AnimationPlayer = %AnimationPlayer
@onready var player_sprite: Sprite2D = %player_sprite
@onready var tackle_damage_emitter_area : Area2D = %TackleDamageEmiiterArea
@onready var control_sprite: Sprite2D = %ControlSprite
@onready var opponent_detection_area: Area2D = %OpponentDetectionArea
@onready var permanent_damage_emiter_area : Area2D = %PermanentDamageEmiterArea
@onready var goalie_hands_collider : CollisionShape2D = %GoalieHandsCollider
@onready var root_particles : Node2D = %RootParticles
@onready var run_particles : GPUParticles2D = %RunParticles


var ai_behavior_factory := AIBehaviorFactory.new()
var country := ""
var current_ai_behavior : AIBehavior = null
var current_state: PlayerState = null
var fullname := ""
var heading := Vector2.RIGHT
var height := 0.0
var height_velocity := 0.0
var role : Role = Role.GOALIE
var skin_color := Player.SkinColor.MEDIUM
var spawn_position := Vector2.ZERO
var state_factory := PlayerStateFactory.new()
var weight_on_duty_steering := 0.0
var kickoff_position := Vector2.ZERO

func _ready() -> void:
	set_control_texture()
	setup_ai_behavior()
	set_sprite()
	set_shader_properties()
	permanent_damage_emiter_area.monitoring = role == Role.GOALIE
	goalie_hands_collider.disabled = role != Role.GOALIE
	tackle_damage_emitter_area.body_entered.connect(on_tackle_player.bind())
	permanent_damage_emiter_area.body_entered.connect(on_tackle_player.bind())
	spawn_position = position
	GameEvents.team_scored.connect(on_team_scored.bind())
	GameEvents.game_over.connect(on_game_over.bind())
	var initial_position := kickoff_position if country == GameManager.current_matchup.country_home else spawn_position
	switch_states(State.RESETTING, PlayerStateData.build().set_reset_position(initial_position))

func _process(delta: float) -> void:
	flip_sprites()
	set_sprite_visibility()
	process_gravity(delta)
	move_and_slide()

func set_sprite() -> void:
	if country == "MARS":
		var alien_texture = load("res://assets/art/characters/alien-soccer-player.png")
		player_sprite.texture = alien_texture

func set_shader_properties() -> void:
	player_sprite.material.set_shader_parameter("skin_color", skin_color)
	var countries = DataLoader.get_countries()
	var country_color := countries.find(country)
	country_color = clampi(country_color, 0, countries.size() - 1)
	player_sprite.material.set_shader_parameter("team_color", country_color)

func initialize(context_position: Vector2, context_ball: Ball, context_own_goal: Goal,
				context_target_goal: Goal, context_player_data: PlayerResource, context_country: String,
				context_kickoff_position: Vector2) -> void:
	position = context_position
	ball = context_ball
	own_goal = context_own_goal
	target_goal = context_target_goal
	speed = context_player_data.speed
	carry_speed = speed - 5
	power = context_player_data.power
	role = context_player_data.role
	skin_color = context_player_data.skin_color
	fullname = context_player_data.full_name
	heading = Vector2.LEFT if target_goal.position.x < position.x else Vector2.RIGHT
	country = context_country
	kickoff_position = context_kickoff_position

func setup_ai_behavior() -> void:
	current_ai_behavior = ai_behavior_factory.get_ai_behavior(role)
	current_ai_behavior.setup(self, ball, opponent_detection_area, teammate_detection_area)
	current_ai_behavior.name = "AI Behavior"
	add_child(current_ai_behavior)

func switch_states(state: State, state_data: PlayerStateData = PlayerStateData.new()) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self, state_data, animation_player, ball, teammate_detection_area,
						ball_detection_area, own_goal, target_goal, tackle_damage_emitter_area, current_ai_behavior)
	current_state.state_transition_requested.connect(switch_states.bind())
	current_state.name = "PlayerStateMachine: " + str(state)
	call_deferred("add_child", current_state)

func set_movement_animation() -> void:
	var vel_length := velocity.length()
	if vel_length < 1:
		animation_player.play('idle')
	elif vel_length < speed * WALK_ANIM_THRESHOLD:
		animation_player.play('walk')
	else:
		animation_player.play('run')

func process_gravity(delta: float) -> void:
	if height > 0:
		height_velocity -= GRAVITY * delta
		height += height_velocity
		if height <= 0:
			height = 0
	player_sprite.position = Vector2.UP * height

func set_heading() -> void:
	if velocity.x > 0:
		heading = Vector2.RIGHT
	elif velocity.x < 0:
		heading = Vector2.LEFT

func face_towards_target_goal() -> void:
	if not is_facing_target_goal():
		heading = heading * -1

func flip_sprites() -> void:
	if heading == Vector2.RIGHT:
		player_sprite.flip_h = false
		tackle_damage_emitter_area.scale.x = 1
		opponent_detection_area.scale.x = 1
		root_particles.scale.x = 1
	elif heading == Vector2.LEFT:
		player_sprite.flip_h = true
		tackle_damage_emitter_area.scale.x = -1
		opponent_detection_area.scale.x = -1
		root_particles.scale.x = -1

func set_control_scheme(scheme: ControlScheme) -> void:
	control_scheme = scheme
	set_control_texture()

func set_sprite_visibility() -> void:
	control_sprite.visible = has_ball() or not control_scheme == ControlScheme.CPU
	run_particles.emitting = velocity.length() == speed

func get_hurt(hurt_origin: Vector2) -> void:
	var data = PlayerStateData.build().set_hurt_direction(hurt_origin)
	was_tackled.emit()
	switch_states(Player.State.HURT, data)

func has_ball() -> bool:
	return ball.carrier == self

func is_ready_for_kickoff() -> bool:
	return current_state != null and current_state.is_ready_for_kickoff()

func set_control_texture() -> void:
	control_sprite.texture = CONTROL_SCHEME_MAP[control_scheme]

func get_pass_request(player: Player) -> void:
	if ball.carrier == self and current_state != null and current_state.can_pass():
		switch_states(Player.State.PASSING, PlayerStateData.build().set_pass_target(player))

func is_facing_target_goal() -> bool:
	var direction_to_target_goal := position.direction_to(target_goal.position)
	return heading.dot(direction_to_target_goal) > 0

func can_carry_ball() -> bool:
	return current_state != null and current_state.can_carry_ball()

func on_tackle_player(player: Player) -> void:
	if player != self and player.country != country and player == ball.carrier:
		player.get_hurt(position.direction_to(player.position))

func on_animation_complete() -> void:
	if current_state != null:
		current_state.on_animation_complete()

func on_team_scored(team_scored_on: String) -> void:
	if country == team_scored_on:
		switch_states(Player.State.MOURNING)
	else:
		switch_states(Player.State.CELEBRATING)

func on_game_over(winning_team: String) -> void:
	if country == winning_team:
		switch_states(Player.State.CELEBRATING)
	else:
		switch_states(Player.State.MOURNING)

func control_ball() -> void:
	if ball.height > BALL_CONTROL_HEIGHT_MAX:
		switch_states(State.CHEST_CONTROL)
