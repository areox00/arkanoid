extends CollisionObject2D
class_name BrickPreview

export var resource: Resource setget set_resource;
export var removable := true;

func _input_event(viewport, event, shape_idx):
	if event is InputEvent and removable:
		if Input.is_action_pressed("remove_brick"):
			queue_free();

func set_resource(new_resource):
	resource = new_resource;
	if resource is BrickResource:
		modulate = (resource as BrickResource).color;
