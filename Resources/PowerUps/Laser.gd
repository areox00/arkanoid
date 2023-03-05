extends PowerUpResource
class_name Laser

func _activate(event_bus: GameEvents):
	event_bus.emit_signal("powerup_laser");
