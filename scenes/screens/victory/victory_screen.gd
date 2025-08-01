class_name VictoryScreen
extends Screen

@onready var winner_background := %WinnerBackground
@onready var shadow_enter := %shadow_enter
@onready var shadow := %shadow
@onready var particle_1 := %particle_1
@onready var particle_2 := %particle_2
@onready var particle_3 := %particle_3

var tournament : Tournament
var start_time := Time.get_ticks_msec()
var played_animation := false
var locked := false

const TIME_UNTIL_ANIMATION_START := 4000  # 4 seconds to line up with music
const WAIT_DURATION := 8000 # Wait 6 seconds to transition cutscene if a key wasn't pressed

func _ready() -> void:
	var do_skin := true
	shadow.position.x = -288.0
	start_time = Time.get_ticks_msec()
	tournament = screen_data.tournament
	if tournament.current_stage == Tournament.Stage.LOCKED:
		particle_1.emitting = false
		particle_2.emitting = false
		particle_3.emitting = false
		locked = true
		screen_data.tournament.advance()
		MusicPlayer.play_music(MusicPlayer.Music.FAKE_WIN, 0.5)
	else:
		if "MARS" in GameManager.player_setup:
			var alien_texture = load("res://assets/art/ui/victory/alien_winners.png")
			winner_background.texture = alien_texture
			do_skin = false
		locked = false
		MusicPlayer.play_music(MusicPlayer.Music.WIN, 0.5)
	set_shader_properties(do_skin)

func _process(_delta: float) -> void:
	if locked and not played_animation and Time.get_ticks_msec() - start_time > TIME_UNTIL_ANIMATION_START:
		shadow_enter.play("enter_shadow")
		played_animation = true
	if KeyUtiles.is_action_just_press(Player.ControlScheme.P1, KeyUtiles.Action.SHOOT):
		if tournament.current_stage == Tournament.Stage.COMPLETE:
			transition_screen(SoccerGame.ScreenType.MAIN_MENU)
		else:
			transition_screen(SoccerGame.ScreenType.ALIEN_CUTSCENE, screen_data)
		SoundPlayer.play(SoundPlayer.Sound.UI_SELECT)
	elif locked and Time.get_ticks_msec() - start_time > WAIT_DURATION:
		transition_screen(SoccerGame.ScreenType.ALIEN_CUTSCENE, screen_data)

func set_shader_properties(use_skin_shader: bool) -> void:
	# Set jersey colors
	var this_stage := tournament.current_stage
	if this_stage == Tournament.Stage.SECRET or (this_stage == Tournament.Stage.COMPLETE and GameManager.mars_unlocked):
		this_stage = Tournament.Stage.LOCKED
	var final_match : Match = tournament.matches[this_stage - 1][0]
	var countries = DataLoader.get_countries()
	var winner_country := countries.find(final_match.winner)
	winner_country = clampi(winner_country, 0, countries.size() - 1)
	var loser_country := countries.find(final_match.loser)
	loser_country = clampi(loser_country, 0, countries.size() - 1)
	var final_countries : Array[int] = [winner_country, loser_country]
	winner_background.material.set_shader_parameter("teams_colors", final_countries)

	# Set skin colors
	if use_skin_shader:
		var players := DataLoader.get_squad(final_match.winner)
		var skin_colors : Array[int]
		for i in players.size():
			var player_data := players[i] as PlayerResource
			skin_colors.append(player_data.skin_color)
		winner_background.material.set_shader_parameter("skin_colors", skin_colors)
	
