extends PowerUpResource
class_name MoreBalls

func _activate(event_bus: GameEvents):
	event_bus.emit_signal("powerup_more_balls");
