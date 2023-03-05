extends Node2D
class_name Editor

var selected_brick_scene := load("res://Scenes/BrickSelected.tscn");
var preview_brick_scene := load("res://Scenes/BrickPreview.tscn");
var selected_brick: BrickPreview;
onready var bricks_container = $Bricks;

onready var game_data := $"/root/game_data" as GameData;

var edge_left: int;
var edge_right: int;
var edge_top: int;
var edge_bottom: int;

var can_put := true;
var collisions := 0;

func _ready():
	selected_brick = selected_brick_scene.instance();
	selected_brick.modulate.a = 0.5;
	add_child(selected_brick);
	
	edge_left = $Edges/Left.global_position.x;
	edge_right = $Edges/Right.global_position.x;
	edge_top = $Edges/Top.global_position.y;
	edge_bottom = $Edges/Bottom.global_position.y;
	
	selected_brick.connect("body_exited", self, "enable_put");
	selected_brick.connect("body_entered", self, "disable_put");
	
	for i in get_tree().get_nodes_in_group("brick_button"):
		var button := i.get_node("Button") as Button;
		var resource := (i.get_node("Brick") as BrickButton).resource as BrickResource;
		button.connect("pressed", self, "set_brick", [resource]);
		
	var brick_scene := load("res://Scenes/BrickPreview.tscn");
	
	for i in game_data.sector_resource.bricks:
		var brick := brick_scene.instance() as BrickPreview;
		brick.add_to_group("brick");
		brick.global_position = i["position"];
		brick.resource = i["resource"];
		$"Bricks".add_child(brick);
		
	$UI/SectorName.text = game_data.sector_name;

func set_brick(resource: BrickResource):
	selected_brick.resource = resource;
	selected_brick.modulate.a = 0.5;

func enable_put(body: Node):
	collisions -= 1;
	if collisions == 0:
		selected_brick.modulate = (selected_brick.resource as BrickResource).color;
		selected_brick.modulate.a = 0.5;
		can_put = true;

func disable_put(body: Node):
	collisions += 1;
	selected_brick.modulate.r = 1.0;
	selected_brick.modulate.g = 0.5;
	selected_brick.modulate.b = 0.5;
	selected_brick.modulate.a = 0.5;
	can_put = false;

func put_brick():
	if Input.is_action_pressed("put_brick") and can_put:
		var created_brick := preview_brick_scene.instance() as BrickPreview;
		created_brick.global_position = selected_brick.global_position;
		created_brick.resource = selected_brick.resource;
		created_brick.add_to_group("brick");
		bricks_container.add_child(created_brick);

func _physics_process(delta):
	var rounded_x = round(get_global_mouse_position().x / 20) * 20;
	var rounded_y = round(get_global_mouse_position().y / 20) * 20;

	var mouse_pos = get_global_mouse_position();
	
	if mouse_pos.x >= edge_left and mouse_pos.x <= edge_right \
	   and mouse_pos.y >= edge_top and mouse_pos.y <= edge_bottom:
		selected_brick.global_position = Vector2(
			clamp(rounded_x, edge_left+80/2, edge_right-80/2), 
			clamp(rounded_y, edge_top+40/2, edge_bottom-40/2) \
		);
		
		yield(get_tree(), "physics_frame");
		put_brick();
