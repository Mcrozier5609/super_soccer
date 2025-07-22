extends Node

enum Sound {BOUNCE, HURT, PASS, POWERSHOT, SHOT, TACKLE, UI_NAV, UI_SELECT, WHISTLE, CROWD}

const NUM_CHANNELS := 5
const SFX_MAP: Dictionary[Sound, AudioStream] = {
	Sound.BOUNCE: preload("res://assets/sfx/bounce.wav"),
	Sound.HURT: preload("res://assets/sfx/hurt.wav"),
	Sound.PASS: preload("res://assets/sfx/pass.wav"),
	Sound.POWERSHOT: preload("res://assets/sfx/power-shot.wav"),
	Sound.SHOT: preload("res://assets/sfx/shoot.wav"),
	Sound.TACKLE: preload("res://assets/sfx/tackle.wav"),
	Sound.UI_NAV: preload("res://assets/sfx/ui-navigate.wav"),
	Sound.UI_SELECT: preload("res://assets/sfx/ui-select.wav"),
	Sound.WHISTLE: preload("res://assets/sfx/whistle.wav"),
	Sound.CROWD: preload("res://assets/sfx/crowd_sfx_wav.wav"),
}

var stream_players : Array[AudioStreamPlayer] = []

var crowd_player : AudioStreamPlayer

func _ready() -> void:
	for i in range(NUM_CHANNELS):
		var stream_player := AudioStreamPlayer.new()
		stream_players.append(stream_player)
		add_child(stream_player)
	crowd_player = AudioStreamPlayer.new()
	add_child(crowd_player)
	crowd_player.stream = SFX_MAP[Sound.CROWD]

func play(sound: Sound) -> void:
	var stream_player := find_first_available_player()
	if stream_player != null:
		stream_player.stream = SFX_MAP[sound]
		stream_player.play()

func find_first_available_player() -> AudioStreamPlayer:
	for stream_player in stream_players:
		if not stream_player.playing:
			return stream_player
	return null
			
