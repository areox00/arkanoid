extends Camera2D

var shake_force := 1.0;
var shake := false;

func stop():
	shake = false;

func shake(var force, var seconds):
	shake = true;
	shake_force = force;
	
	var timer := get_tree().create_timer(seconds);
	timer.connect("timeout", self, "stop");
	
func _process(delta):
	if !shake:
		return;

	set_offset(Vector2( \
		rand_range(-1.0, 1.0) * shake_force, \
		rand_range(-1.0, 1.0) * shake_force \
	));
