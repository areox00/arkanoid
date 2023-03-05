extends Node
class_name Bricks

var brick_scene := load("res://Scenes/Brick.tscn");

var amount: int;

func clear_bricks():
	for n in get_children():
		n.queue_free();

func create_bricks(var sector: SectorResource, var sector_num: int):
	amount = 0;
	
	for i in sector.bricks:
		yield(get_tree().create_timer(0.01), "timeout");
	
		var instance := brick_scene.instance() as Brick;
		instance.resource = i["resource"];
		add_child(instance);
		
		instance.global_position = i["position"];
		
		if (i["resource"] as BrickResource).durability > 0:
			amount += 1;
			
		if (i["resource"] as BrickResource).incremental:
			instance.health += floor(sector_num / 8.0);
			instance.resource.points = 50 * sector_num;
