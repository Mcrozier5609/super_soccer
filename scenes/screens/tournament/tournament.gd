class_name Tournament

enum Stage {QUARTER_FINALS, SEMI_FINALS, FINAL, SECRET, COMPLETE}

var current_stage : Stage = Stage.QUARTER_FINALS
var matches := {
	Stage.QUARTER_FINALS: [],
	Stage.SEMI_FINALS: [],
	Stage.FINAL: [],
	Stage.SECRET: [],
}

var winner := ""

func _init() -> void:
	var countries := DataLoader.get_countries().slice(1, 10)
	countries.shuffle()
	if countries[-1] != GameManager.player_setup[0]:
		countries.pop_at(-1)
	else:
		countries.pop_at(-2)
	create_bracket(Stage.QUARTER_FINALS, countries)

func create_bracket(stage: Stage, countries: Array[String]) -> void:
	for i in range(int(countries.size() / 2.0)):
		matches[stage].append(Match.new(countries[i * 2], countries[i * 2 + 1]))

func advance() -> void:
	if current_stage < Stage.COMPLETE:
		var stage_matches : Array = matches[current_stage]
		var stage_winners : Array[String] = []
		for current_match : Match in stage_matches:
			current_match.resolve()
			stage_winners.append(current_match.winner)
		current_stage = current_stage + 1 as Stage
		if current_stage == Stage.COMPLETE:
			winner = stage_winners[0]
		else:
			if current_stage == Stage.SECRET:
				var secrect_stage_players : Array[String] = [stage_winners[0], 'MARS']
				stage_winners = secrect_stage_players
			create_bracket(current_stage, stage_winners)
