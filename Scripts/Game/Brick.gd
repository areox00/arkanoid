extends StaticBody2D
class_name Brick

var resource: BrickResource;
onready var event_bus := $"../%GameEventsBus" as GameEvents;
var health: int;

func hit():
	var brick_resource := resource as BrickResource;
	if brick_resource.durability <= 0:
		return;
	
	health -= 1;
	if health == 0:
		event_bus.emit_signal("brick_destroyed", self);
		($Collision as CollisionShape2D).disabled = true;
		queue_free();

func _ready():
	health = resource.durability;
	modulate = resource.color;

func _process(delta):
	pass
