class_name TeamSelectionScreen
extends Control

const FLAG_ANCHOR_POINT := Vector2(35, 80)
const FlAG_SELECTOR_PREFAB := preload("res://scenes/team_selection/flag_selector.tscn")
const NUM_ROWS := 2
const NUM_COLS := 4

@onready var flags_container : Control = %FlagsContainer

var move_dirs : Dictionary[KeyUtiles.Action, Vector2i] = {
	KeyUtiles.Action.UP: Vector2i.UP,
	KeyUtiles.Action.DOWN: Vector2i.DOWN,
	KeyUtiles.Action.LEFT: Vector2i.LEFT,
	KeyUtiles.Action.RIGHT: Vector2i.RIGHT,
}
var selection : Array[Vector2i] = [Vector2i.ZERO, Vector2i.ZERO]
var selectors : Array[FlagSelector] = []

func _ready() -> void:
	place_flags()
	place_selectors()

func _process(_delta: float) -> void:
	for i in range(selectors.size()):
		var selector = selectors[i]
		if not selector.is_selected:
			for action : KeyUtiles.Action in move_dirs.keys():
				if KeyUtiles.is_action_just_press(selector.control_scheme, action):
					try_navigate(i, move_dirs[action])

func try_navigate(selector_index: int, direction: Vector2i) -> void:
	var rect: Rect2i = Rect2i(0, 0, NUM_COLS, NUM_ROWS)
	if rect.has_point(selection[selector_index] + direction):
		selection[selector_index] += direction
		var flag_index := selection[selector_index].x + selection[selector_index].y * NUM_COLS
		selectors[selector_index].position = flags_container.get_child(flag_index).position
		SoundPlayer.play(SoundPlayer.Sound.UI_NAV)

func place_flags() -> void:
	for j in range(NUM_ROWS):
		for i in range(NUM_COLS):
			var flag_texture := TextureRect.new()
			flag_texture.position = FLAG_ANCHOR_POINT + Vector2(55 * i, 50 * j)
			var country_index := 1 + i + NUM_COLS * j
			var country := DataLoader.get_countries()[country_index]
			flag_texture.texture = FlagHelper.get_texture(country)
			flag_texture.scale = Vector2(2,2)
			flag_texture.z_index = 1
			flags_container.add_child(flag_texture)

func place_selectors() -> void:
	add_selector(Player.ControlScheme.P1)
	if not GameManager.player_setup[1].is_empty():
		add_selector(Player.ControlScheme.P2)

func add_selector(control_scheme: Player.ControlScheme) -> void:
	var selector := FlAG_SELECTOR_PREFAB.instantiate()
	selector.position = flags_container.get_child(0).position
	selector.control_scheme = control_scheme
	selectors.append(selector)
	flags_container.add_child(selector)
