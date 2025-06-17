class_name FlagSelector
extends Control

signal selected

@onready var animation_player : AnimationPlayer = %AnimationPlayer
@onready var indicator_1p : TextureRect = %Indicator1P
@onready var indicator_2p : TextureRect = %Indicator2P

var control_scheme := Player.ControlScheme.P1
var is_selected := false
var selector_index := 0
var selector_coords := Vector2i.ZERO

func _ready() -> void:
	indicator_1p.visible = control_scheme == Player.ControlScheme.P1
	indicator_2p.visible = control_scheme == Player.ControlScheme.P2

	selector_index = 1 if control_scheme == Player.ControlScheme.P2 else 0

func _process(_delta: float) -> void:
	if not is_selected and KeyUtiles.is_action_just_press(control_scheme, KeyUtiles.Action.SHOOT):
		print(selector_coords)
		if selector_coords == Vector2i(4, 1) and not GameManager.mars_unlocked:
			animation_player.play("unavailable")
			SoundPlayer.play(SoundPlayer.Sound.BOUNCE)
		else:
			is_selected = true
			animation_player.play("selected")
			SoundPlayer.play(SoundPlayer.Sound.UI_SELECT)
			selected.emit()
	elif is_selected and KeyUtiles.is_action_just_press(control_scheme, KeyUtiles.Action.PASS):
		is_selected = false
		animation_player.play("selecting")
		SoundPlayer.play(SoundPlayer.Sound.PASS)

func play_selecting_animation() -> void:
	animation_player.play("selecting")
