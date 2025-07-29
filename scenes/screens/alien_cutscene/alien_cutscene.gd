class_name AlienCutscene
extends Screen

@onready var space_background := %SpaceBackground
@onready var space_ship := %SpaceShip
@onready var animation_player := %AnimationPlayer
@onready var tractor_beam := %TractorBeam
@onready var crowd_beam := %CrowdBeam
@onready var silhouette := %Silhouette
@onready var aliens := %Aliens

var start_time := Time.get_ticks_msec()
var did_beam := false
var went_ground := false
var did_fade := false
var showed_closeup := false

const BEAM_START := 3000
const GO_GROUND_START := 5000
const FADE_START := 7000
const ALIEN_CLOSEUP_START := 11000
const FINISH_TIME := 17000

func _ready() -> void:
	start_time = Time.get_ticks_msec()

func _process(_delta: float) -> void:
	if KeyUtiles.is_action_just_press(Player.ControlScheme.P1, KeyUtiles.Action.SHOOT):
		transition_screen(SoccerGame.ScreenType.TOURNAMENT, screen_data)
	if not did_beam and Time.get_ticks_msec() - start_time > BEAM_START:
		did_beam = true
		animation_player.play("beam_start")
	if not went_ground and Time.get_ticks_msec() - start_time > GO_GROUND_START:
		went_ground = true
		space_background.position.x = -280.0
		space_ship.position.x = -280.0
		tractor_beam.position.x = -280
		crowd_beam.position.x = 0
		silhouette.position.x = 0
	if not did_fade and Time.get_ticks_msec() - start_time > FADE_START:
		did_fade = true
		animation_player.play("fade_aliens")
	if not showed_closeup and Time.get_ticks_msec() - start_time > ALIEN_CLOSEUP_START:
		showed_closeup = true
		aliens.position.x = 0
		space_background.position.x = 0
		crowd_beam.position.x = -280
		silhouette.position.x = -280
		space_ship.position.x = -280.0
		tractor_beam.position.x = -280
	if Time.get_ticks_msec() - start_time > FINISH_TIME:
		transition_screen(SoccerGame.ScreenType.TOURNAMENT, screen_data)

func start_bob_again() -> void:
	animation_player.play("space_ship_bob")
