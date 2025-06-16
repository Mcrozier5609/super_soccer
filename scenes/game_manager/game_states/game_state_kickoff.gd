class_name GameStateKickoff
extends GameState

var valid_control_schemes := []
var random_cpu_kickoff_time := 0
var kickoff_start = Time.get_ticks_msec()

func _enter_tree():
	kickoff_start = Time.get_ticks_msec()
	var country_starting := state_data.country_scored_on
	if country_starting.is_empty():
		country_starting = manager.countries[0]
	if country_starting == manager.player_setup[0]:
		valid_control_schemes.append(Player.ControlScheme.P1)
	if country_starting == manager.player_setup[1]:
		valid_control_schemes.append(Player.ControlScheme.P2)
	if valid_control_schemes.size() == 0:
		random_cpu_kickoff_time = randi_range(1000, 3000)

func _process(_delta: float) -> void:
	if valid_control_schemes.size() > 0:
		for control_scheme : Player.ControlScheme in valid_control_schemes:
			if KeyUtiles.is_action_just_press(control_scheme, KeyUtiles.Action.PASS):
				GameEvents.kickoff_started.emit()
				SoundPlayer.play(SoundPlayer.Sound.WHISTLE)
				transition_state(GameManager.State.IN_PLAY)
	elif Time.get_ticks_msec() - kickoff_start > random_cpu_kickoff_time:
		GameEvents.kickoff_started.emit()
		SoundPlayer.play(SoundPlayer.Sound.WHISTLE)
		transition_state(GameManager.State.IN_PLAY)
