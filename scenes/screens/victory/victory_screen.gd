class_name VictoryScreen
extends Screen

@onready var winner_background := %WinnerBackground

func _ready() -> void:
	MusicPlayer.play_music(MusicPlayer.Music.WIN, 0.5)
	set_shader_properties()

func _process(_delta: float) -> void:
	pass

func set_shader_properties() -> void:
	var skin_colors : Array[int] = [0,1,2,0,1,2]
	winner_background.material.set_shader_parameter("skin_colors", skin_colors)
	#var countries = DataLoader.get_countries()
	#var country_colors := countries.find(country)
	#country_colors = clampi(country_color, 0, countries.size() - 1)
	var country_colors : Array[int] = [8, 6]
	winner_background.material.set_shader_parameter("teams_colors", country_colors)
