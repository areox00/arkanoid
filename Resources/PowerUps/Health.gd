extends PowerUpResource
class_name Health

func _activate(event_bus: GameEvents):
	event_bus.emit_signal("powerup_health");
