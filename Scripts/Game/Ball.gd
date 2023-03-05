extends KinematicBody2D
class_name Ball

var paused := false;
var is_dead := false;
var speed_factor := 1.0;

var speed := 850;
var direction := Vector2(0, -1);

signal death;

var particle_ball_scene := load("res://Scenes/Particles/ParticleBallHit.tscn");

var hit_factor := 0.0;

var stronger := false;
var skip_bounce := false;
var shake_amount := 1.0;

var can_catch := false;

func enable_catching():
	can_catch = true;

func disable_catching():
	can_catch = false;

func release(release_direction: float, parent: Node):
	if paused:
		paused = false;
		set_collision_mask_bit(0, true);
		reparent(parent);
		if hit_factor == 0:
			direction.x = release_direction;
		else:
			direction.x = hit_factor;
		direction.y = -1;

func lock(new_parent: Node):
	set_collision_mask_bit(0, false);
	paused = true;
	reparent(new_parent);

func make_stronger_damage():
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT);
	tween.tween_property($Trail, "modulate:a", 1.0, 0.2);
	tween.parallel().tween_property($Body, "modulate", Color(1.0, 0.5, 0.5, 1.0), 0.2);
	
	shake_amount = 3.0;
	stronger = true;

func make_normal_damage():
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT);
	tween.tween_property($Trail, "modulate:a", 0.0, 0.2);
	tween.parallel().tween_property($Body, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2);
	
	shake_amount = 1.0;
	stronger = false;

func _draw():
	pass; #draw_circle(Vector2.ZERO, 10, Color(1.0, 1.0, 1.0));

func _ready():
	var angle_delta: float = (PI * 2) / 20;
	var vector: Vector2 = Vector2(10, 0);
	var polygon: PoolVector2Array;
	
	for _i in 20:
		polygon.append(vector);
		vector = vector.rotated(angle_delta);
	
	#$Polygon2D.polygon = polygon;
	
func bounce(normal: Vector2):
	if stronger and !skip_bounce:
		skip_bounce = true;
		return;
		
	direction = direction.bounce(normal);
	skip_bounce = false;
	
func reparent(new_parent: Node):
	var old_transform = global_transform;
	get_parent().remove_child(self);
	new_parent.add_child(self);
	global_transform = old_transform;
	
func _physics_process(delta):
	if paused:
		return;
		
	var collision := move_and_collide(direction.normalized() * speed * delta * speed_factor);
	
	if collision:
		if !collision.collider.is_in_group("paddle") and !is_dead:
			get_node("/root/Gameplay/Camera2D").shake(shake_amount, 0.2);
			
			var instance := particle_ball_scene.instance() as Particles2D;
			instance.speed_scale = speed_factor;
			instance.modulate = collision.collider.modulate;
			instance.rotation = collision.normal.angle();
			instance.global_position = self.global_position;
			get_parent().add_child(instance);
			
			
		if collision.collider.is_in_group("paddle"):
			hit_factor = \
				(self.global_position.x - collision.collider.global_position.x) / 140.0;
			
			if can_catch:
				lock(collision.collider);
			
			if hit_factor < 0.5 and hit_factor > -0.5:
				if hit_factor < 0 and direction.x > 0 or hit_factor > 0 and direction.x < 0:
					hit_factor = -hit_factor;
					
			direction = Vector2(hit_factor * 2, -direction.y);
			$HitPaddle.play();
		elif collision.collider.is_in_group("brick"):
			var hit_brick := (collision.collider as Brick);
			bounce(collision.normal);
			hit_brick.hit();
			$HitBrick.play();
		elif collision.collider.is_in_group("death"):
			if !is_dead:
				emit_signal("death");
				is_dead = true;
		elif collision.collider.is_in_group("boss"):
			(collision.collider as Boss).hit();
			bounce(collision.normal);
			$HitBoss.play();
		else:
			$HitWall.play();
			bounce(collision.normal);
