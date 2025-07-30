class_name Tournament

enum Stage {QUARTER_FINALS, SEMI_FINALS, FINAL, LOCKED, SECRET, COMPLETE}

var current_stage : Stage = Stage.QUARTER_FINALS
var matches := {
	Stage.QUARTER_FINALS: [],
	Stage.SEMI_FINALS: [],
	Stage.FINAL: [],
	Stage.LOCKED: [],
	Stage.SECRET: [],
}

var winner := ""
var country_max := 10
var excluded_max := 1

func _init() -> void:
	if GameManager.mars_unlocked:
		country_max += 1
		excluded_max += 1
	var countries := DataLoader.get_countries().slice(1, country_max)
	countries.shuffle()
	var num_excluded := 0
	var country_index := 0
	while num_excluded < excluded_max:
		if countries[0] != GameManager.player_setup[0]:
			countries.pop_at(country_index)
			num_excluded += 1
		else:
			country_index += 1
	create_bracket(Stage.QUARTER_FINALS, countries)

func create_bracket(stage: Stage, countries: Array[String]) -> void:
	for i in range(int(countries.size() / 2.0)):
		matches[stage].append(Match.new(countries[i * 2], countries[i * 2 + 1]))

func advance() -> void:
	if current_stage < Stage.COMPLETE:
		var this_stage := current_stage
		if current_stage == Stage.LOCKED:
			this_stage = current_stage - 1 as Stage
		var stage_matches : Array = matches[this_stage]
		var stage_winners : Array[String] = []
		for current_match : Match in stage_matches:
			if current_stage != Stage.LOCKED:
				current_match.resolve()
			stage_winners.append(current_match.winner)
		current_stage = current_stage + 1 as Stage
		if current_stage == Stage.LOCKED and GameManager.mars_unlocked:
			current_stage = Stage.COMPLETE
		if current_stage == Stage.COMPLETE:
			winner = stage_winners[0]
		else:
			if current_stage == Stage.SECRET:
				var secrect_stage_players : Array[String] = [stage_winners[0], 'MARS']
				stage_winners = secrect_stage_players
			create_bracket(current_stage, stage_winners)
