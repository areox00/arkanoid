tool
extends StaticBody2D
class_name BrickButton

export var resource: Resource;

func _process(delta):
	if Engine.editor_hint and resource:
		modulate = resource.color;
