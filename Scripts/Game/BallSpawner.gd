extends Node
class_name BallSpawner

var ball_scene := load("res://Scenes/Ball.tscn");

var spawned_balls := 0;

signal all_dead;

func spawn_more_balls(position: Vector2):
	for i in range(3):
		spawn_ball(position);

func track_death(ball: Ball):
	spawned_balls -= 1;
	if spawned_balls == 0:
		emit_signal("all_dead");
	else:
		ball.queue_free();

func kill_all():
	spawned_balls = 0;
	get_tree().call_group("ball", "queue_free");

func pick_first() -> Ball:
	for n in get_children():
		if n is Ball:
			return n;
	
	return null;

func spawn_ball(position: Vector2) -> Ball:
	var rng := RandomNumberGenerator.new();
	rng.randomize();
	
	var instance = ball_scene.instance() as Ball;
	instance.global_position = position;
	instance.direction.x = rng.randf_range(-1, 1);
	instance.direction.y = -1;
	instance.connect("death", self, "track_death", [instance]);
	
	#call_deferred("add_child", instance);
	add_child(instance);
	spawned_balls += 1;
	
	return instance;
	
func _process(delta):
	pass;
