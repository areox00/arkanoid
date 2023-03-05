extends KinematicBody2D
class_name Boss

var speed := 0.0;
var max_speed := 500.0;
var direction: Vector2;
var paused := false;

var direction_timer := Timer.new();

var tween: SceneTreeTween;

var hp := 15;

signal death;

var bullet_scene = load("res://Scenes/Bullet.tscn");

func change_direction():
	var rng := RandomNumberGenerator.new();
	rng.randomize();
	
	direction = Vector2(rng.randi_range(-1, 1), rng.randi_range(-1, 1));
	
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT);
	tween.tween_property(self, "speed", max_speed, 0.75);
	tween.tween_property(self, "speed", 0.0, 0.75);

	for i in range(3):
		var instance := bullet_scene.instance() as Bullet;
		instance.global_position = global_position;
		instance.global_position.y += 200;
		instance.direction = Vector2(-1 + i, 1);
		instance.rotation = 45 + i * -45;
		get_parent().add_child(instance);
		
	$Sound.play();

func on_death():
	emit_signal("death");

func hit():
	#$sprite.material.set_shader_param("OUTLINE_COLOR", Color.purple)
	
	tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT);
	tween.tween_property($Sprite.material, "shader_param/hit_mix", 0.65, 0.15);
	tween.tween_property($Sprite.material, "shader_param/hit_mix", 0.0, 0.3);

	hp -= 1;
	if hp == 0:
		tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT);
		tween.tween_property($Sprite.material, "shader_param/explosion_progress", 0.0, 1.0);
		tween.parallel().tween_property(self, "scale", Vector2(2.5, 2.5), 1.0);
		$CollisionShape2D.disabled = true;
		$Trail.visible = false;
		direction_timer.stop();
		direction = Vector2.ZERO;
		
		tween.connect("finished", self, "on_death");

func _ready():
	direction_timer.autostart = true;
	direction_timer.wait_time = 2.0;
	add_child(direction_timer);
	direction_timer.connect("timeout", self, "change_direction");

func _process(delta):
	direction_timer.paused = paused;
		
func _physics_process(delta):
	var collision := move_and_collide(direction.normalized() * speed * delta);
	if collision:
		direction = direction.bounce(collision.normal);
