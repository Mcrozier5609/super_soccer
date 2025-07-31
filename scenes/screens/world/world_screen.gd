class_name WorldScreen
extends Screen

@onready var game_over_timer := %GameOverTimer


func _enter_tree() -> void:
	if GameManager.current_matchup.country_home == "MARS" or GameManager.current_matchup.country_away == "MARS":
		MusicPlayer.play_music(MusicPlayer.Music.ALIEN_GAMEPLAY)
	else:
		MusicPlayer.play_music(MusicPlayer.Music.GAMEPLAY, 0.3)
	GameEvents.game_over.connect(on_game_over.bind())
	GameManager.start_game()
	SoundPlayer.crowd_player.play()

func _exit_tree() -> void:
	SoundPlayer.crowd_player.stop()

func _ready() -> void:
	game_over_timer.timeout.connect(on_transition.bind())

func on_transition() -> void:
	if screen_data.tournament != null and GameManager.current_matchup.winner == GameManager.player_setup[0]:
		screen_data.tournament.advance()
		transition_screen(SoccerGame.ScreenType.TOURNAMENT, screen_data)
	else:
		transition_screen(SoccerGame.ScreenType.MAIN_MENU)

func on_game_over(_winner: String) -> void:
	game_over_timer.start()
