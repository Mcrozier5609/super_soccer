class_name VictoryScreen
extends Screen

@onready var winner_background := %WinnerBackground

func _ready() -> void:
	MusicPlayer.play_music(MusicPlayer.Music.WIN, 0.5)
	set_shader_properties()

func _process(_delta: float) -> void:
	pass

func set_shader_properties() -> void:
	# Set jersey colors
	var tournament : Tournament = screen_data.tournament
	var final_match : Match = tournament.matches[tournament.current_stage - 1][0]
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
	
