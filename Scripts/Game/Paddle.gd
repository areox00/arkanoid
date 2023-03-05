extends KinematicBody2D
class_name Paddle

var direction := Vector2.ZERO;
var speed := 640;
var speed_factor := 1.0;
var paused := false;

onready var animation := $AnimationPlayer as AnimationPlayer;
onready var raycast = $RayCast2D as RayCast2D;
onready var raycast_line = $RayCast2D/Line2D as Line2D;

var particle_laser_scene := load("res://Scenes/Particles/ParticleLaserHit.tscn");
onready var particle_instance := particle_laser_scene.instance() as Particles2D;

signal death;
signal hit;

var is_extend := false;
var is_laser := false;

var timer := Timer.new();
var last_collider: int;

var lives := 5;

func take_live(amount: int):
	lives -= amount;
	emit_signal("hit");
	if lives == 0:
		emit_signal("death");

func add_live(amount: int):
	lives += amount;

func laser_on():
	is_laser = true;
	raycast.visible = true;
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT);
	tween.tween_property(raycast_line.material, "shader_param/laser_size", 0.7, 0.3);

func laser_off():
	is_laser = false;
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT);
	tween.tween_property(raycast_line.material, "shader_param/laser_size", 0.0, 0.3);
	particle_instance.emitting = false;
	

func extend_on():
	#var tween = create_tween().set_trans(Tween.TRANS_ELASTIC);
	#tween.tween_property(self, "scale:x", 1.5, 0.6);
	#tween.parallel().tween_property($Left, "scale:x", 0.5, 0.6);
	#tween.parallel().tween_property($Right, "scale:x", 0.5, 0.6);
	#tween.parallel().tween_property($Detal, "scale:x", 0.5, 0.6);
	
	if !is_extend:
		animation.play("Extend");
		
	is_extend = true;

func extend_off():
	if is_extend:
		is_extend = false;
		animation.play_backwards("Extend");

func _ready():
	#raycast_line.material.set_shader_param("laser_size", 0.0);
	timer.one_shot = true;
	add_child(timer);
	#get_parent().add_child(instance);
	call_deferred("add_child", particle_instance);

func _process(delta):
	direction = Vector2.ZERO;
	
	if paused:
		return;
	
	if Input.is_action_pressed("paddle_right"):
		direction = Vector2.RIGHT;
	if Input.is_action_pressed("paddle_left"):
		direction = Vector2.LEFT;

func _physics_process(delta):
	move_and_slide(direction * speed * speed_factor);
	
	if is_laser:
		var cast_point := raycast.cast_to as Vector2;
		
		if raycast.is_colliding():
			cast_point = to_local(raycast.get_collision_point());
			var collider = raycast.get_collider();
			
			if last_collider != collider.get_instance_id():
				last_collider = collider.get_instance_id();
				timer.start(0.5);
				
			particle_instance.speed_scale = speed_factor;
			#instance.modulate = collider.modulate;
			particle_instance.rotation = raycast.get_collision_normal().angle();
			particle_instance.position = cast_point;
			particle_instance.emitting = true;
				
			if collider.is_in_group("brick") and timer.time_left == 0.0:
				collider.hit();
				timer.start(0.5);
		
		raycast_line.points[1] = cast_point;
