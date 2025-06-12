class_name BallStateData

var intangibility_duration : int

static func build() -> BallStateData:
	return BallStateData.new()

func set_ball_intangibility(duration: int) -> BallStateData:
	intangibility_duration = duration
	return self
