class_name AIBehaviorFactory

var roles: Dictionary

func _init() -> void:
	roles = {
		Player.Role.GOALIE: AIBehaviorGoalie,
		Player.Role.DEFENSE: AIBehaviorFielder,
		Player.Role.MIDFIELD: AIBehaviorFielder,
		Player.Role.OFFENSE: AIBehaviorFielder,
	}

func get_ai_behavior(role: Player.Role) -> AIBehavior:
	assert(roles.has(role), "role doesn't exist!")
	return roles.get(role).new()
