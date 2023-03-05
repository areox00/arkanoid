extends ColorRect

var count := 50;
export (Gradient) var gradient: Gradient;

onready var square_scene := load("res://Scenes/Square.tscn");

var rng := RandomNumberGenerator.new();

func _ready():
	rng.randomize();
	for i in range(count):
		var instance := square_scene.instance() as Node2D;
		var depth := rng.randi_range(3, 6);
		
		instance.modulate = gradient.interpolate(rng.randf());
		
		var offset_y = rng.randi_range(0, self.rect_size.y);
		var offset_x = rng.randi_range(0, self.rect_size.x);

		instance.position = Vector2(offset_x, offset_y);
		
		var random := rng.randf();
		instance.scale = Vector2(random, random);
		
		add_child(instance);


func _physics_process(delta: float):
	for item in get_children():
		var square = item as Node2D;
		square.scale -= Vector2(0.005, 0.005);
		if square.scale.x <= 0:
			var random := rng.randf();
			square.scale = Vector2(random, random);
			
			var offset_y = rng.randi_range(0, self.rect_size.y);
			var offset_x = rng.randi_range(0, self.rect_size.x);
			square.position = Vector2(offset_x, offset_y);
