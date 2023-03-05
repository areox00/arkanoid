extends ColorRect

export var lines := 300;
export var length := 200;
export var speed := 400;
export (Gradient) var gradient;

var rng := RandomNumberGenerator.new();

func _ready():
	rng.randomize();
	for i in range(lines):
		var line := Line2D.new();
		var depth := rng.randi_range(3, 6);
		line.width = depth;
		
		var opacity_step := 30;
		var depth_color = (6 - depth) / 255.0 * opacity_step;
		line.modulate.r -= depth_color;
		line.modulate.g -= depth_color;
		line.modulate.b -= depth_color;
		line.modulate.a -= depth_color;
		
		var final_length = length - ((6 - depth) / length);
		
		var offset_y = rng.randi_range(0, self.rect_size.y);
		var offset_x = rng.randi_range(0, self.rect_size.x);
		line.add_point(Vector2(0, 0));
		line.add_point(Vector2(1 * final_length / 2, 0));
		line.add_point(Vector2(2 * final_length / 2, 0));
		line.gradient = gradient;
		line.position = Vector2(offset_x, offset_y);
		add_child(line);

func _physics_process(delta: float):
	for item in get_children():
		var line = item as Line2D;
		line.position.x -= (speed - speed / line.width) * delta;
		if line.position.x <= -length:
			line.position = Vector2(self.rect_size.x, rng.randi_range(0, self.rect_size.y));
