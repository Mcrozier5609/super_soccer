extends AudioStreamPlayer

enum Music {NONE, GAMEPLAY, MENU, TOURNAMENT, WIN, FAKE_WIN, ALIEN_GAMEPLAY, ALIEN_CUTSCENE}

const MUSIC_MAP : Dictionary[Music, AudioStream] = {
	Music.GAMEPLAY: preload("res://assets/music/soccer_gameplay_mp3.mp3"),
	Music.MENU: preload("res://assets/music/ole_ole_ole_mps.mp3"),
	Music.TOURNAMENT: preload("res://assets/music/soccer_menu_loop.mp3"),
	Music.WIN: preload("res://assets/music/soccer_win_mp3.mp3"),
	Music.FAKE_WIN: preload("res://assets/music/soccer_win_mystery_mp3.mp3"),
	Music.ALIEN_GAMEPLAY: preload("res://assets/music/gameplay.mp3"),
	Music.ALIEN_CUTSCENE: preload("res://assets/music/alien_cuscene_mp3.mp3"),
}

var current_music := Music.NONE

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func play_music(music: Music, volume: float=1.0) -> void:
	if music != current_music and MUSIC_MAP.has(music):
		stream = MUSIC_MAP.get(music)
		current_music = music
		set_volume_linear(volume)
		play()
