extends KinematicBody2D
class_name Bullet

var direction: Vector2;

var particle_ball_scene := load("res://Scenes/Particles/ParticleBallHit.tscn");

func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	var collision := move_and_collide(direction.normalized() * 500 * delta);
	
	if collision:
		if collision.collider.is_in_group("paddle"):
			var paddle := collision.collider as Paddle;
			paddle.take_live(1);
			
		var instance := particle_ball_scene.instance() as Particles2D;
		instance.modulate = collision.collider.modulate;
		instance.rotation = collision.normal.angle();
		instance.global_position = self.global_position;
		get_parent().add_child(instance);
			
		queue_free();
