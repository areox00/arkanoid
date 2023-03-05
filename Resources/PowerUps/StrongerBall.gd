extends PowerUpResource
class_name StrongerBall

func _activate(event_bus: GameEvents):
	event_bus.emit_signal("powerup_stronger_ball");
