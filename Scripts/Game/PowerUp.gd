extends Area2D
class_name PowerUp

export var resource: Resource; 
onready var event_bus := $"../%GameEventsBus" as GameEvents;

func _ready():
	var powerup_resource = resource as PowerUpResource;
	modulate = powerup_resource.color;

func _physics_process(delta: float):
	position.y += 250 * delta;

func _on_enter(body: Node):
	if body.is_in_group("paddle"):
		var powerup_resource = resource as PowerUpResource;
		event_bus.emit_signal("powerup_collected");
		powerup_resource._activate(event_bus);
		queue_free();
