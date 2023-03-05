extends Node2D

export var length := 5;
export var ghost: PackedScene;
var ghost_array: Array;

var step := 1.0;

func _process(delta):
	global_position = Vector2.ZERO;
	
	var instance := ghost.instance() as Node2D;
	instance.global_position = get_parent().global_position;
	add_child(instance);

	step = 1.0;
	for i in ghost_array:
		i.modulate.s = 1.0;
		i.modulate.v = 1.0;
		i.modulate.h = 1.0 / step;
		i.modulate.a = 0.05;
		step += 1.0 / length;

	ghost_array.push_front(instance);
	
	while ghost_array.size() > length:
		ghost_array.back().queue_free();
		ghost_array.pop_back();
