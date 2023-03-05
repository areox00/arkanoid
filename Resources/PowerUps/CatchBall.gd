extends PowerUpResource
class_name CatchBall

func _activate(event_bus: GameEvents):
	event_bus.emit_signal("powerup_catch_ball");
