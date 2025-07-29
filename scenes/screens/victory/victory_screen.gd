class_name VictoryScreen
extends Screen

@onready var winner_background := %WinnerBackground

var tournament : Tournament

func _ready() -> void:
	tournament = screen_data.tournament
	if tournament.current_stage == Tournament.Stage.LOCKED:
		screen_data.tournament.advance()
		MusicPlayer.play_music(MusicPlayer.Music.FAKE_WIN, 0.5)
	else:
		MusicPlayer.play_music(MusicPlayer.Music.WIN, 0.5)
	set_shader_properties()

func _process(_delta: float) -> void:
	if KeyUtiles.is_action_just_press(Player.ControlScheme.P1, KeyUtiles.Action.SHOOT):
		if tournament.current_stage == Tournament.Stage.COMPLETE:
			transition_screen(SoccerGame.ScreenType.MAIN_MENU)
		else:
			transition_screen(SoccerGame.ScreenType.TOURNAMENT, screen_data)
		SoundPlayer.play(SoundPlayer.Sound.UI_SELECT)

func set_shader_properties() -> void:
	# Set jersey colors
	var this_stage := tournament.current_stage
	if this_stage == Tournament.Stage.SECRET:
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
	var players := DataLoader.get_squad(final_match.winner)
	var skin_colors : Array[int]
	for i in players.size():
		var player_data := players[i] as PlayerResource
		skin_colors.append(player_data.skin_color)
	winner_background.material.set_shader_parameter("skin_colors", skin_colors)
	
