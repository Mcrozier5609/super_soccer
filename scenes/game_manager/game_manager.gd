extends Node

const DURATION_IMPAT_PAUSE := 100
const DURATION_GAME_SEC := 2 * 60

enum State {IN_PLAY, SCORED, RESET, KICKOFF, OVERTIME, GAMEOVER}

var current_matchup : Match = null
var current_state : GameState = null
var player_setup : Array[String] = ["FRANCE", ""]
var state_factory := GameStateFactory.new()
var time_left : float
var time_since_paused := Time.get_ticks_msec()

var mars_unlocked := false
var show_mars_flag := false
var selector_coord := Vector2i.ZERO

func _init() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), 0.3)

func _ready() -> void:
	GameEvents.impact_received.connect(on_impact_received.bind())

func _process(_delta: float) -> void:
	if get_tree().paused and Time.get_ticks_msec() - time_since_paused > DURATION_IMPAT_PAUSE:
		get_tree().paused = false

func start_game() -> void:
	time_left = DURATION_GAME_SEC
	switch_states(State.RESET)

func switch_states(state: State, data: GameStateData = GameStateData.new()) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self, data)
	current_state.state_transition_requested.connect(switch_states.bind())
	current_state.name = "GameStateMachine: " + str(state)
	call_deferred("add_child", current_state)

func is_coop() -> bool:
	return player_setup[0] == player_setup[1]

func is_single_player() -> bool:
	return player_setup[1].is_empty()

func is_time_up() -> bool:
	return time_left <= 0

func get_winner_country() -> String:
	assert(not current_matchup.is_tied())
	return current_matchup.winner

func increase_score(country_scored_on: String) -> void:
	current_matchup.increase_score(country_scored_on)
	GameEvents.score_changed.emit()

func on_impact_received(_impact_position: Vector2, is_high_impact: bool) -> void:
	if is_high_impact:
		time_since_paused = Time.get_ticks_msec()
		get_tree().paused = true
