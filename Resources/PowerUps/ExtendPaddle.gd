extends PowerUpResource
class_name ExtendPaddle

func _activate(event_bus: GameEvents):
	event_bus.emit_signal("powerup_extend_paddle");
