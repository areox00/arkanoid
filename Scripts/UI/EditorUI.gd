extends Node
class_name EditorUI

onready var game_data := $"/root/game_data" as GameData;

func back_to_menu():
	get_tree().change_scene("res://Scenes/States/MainMenu.tscn");

func play():
	save_sector();
	get_tree().change_scene("res://Scenes/States/Gameplay.tscn");
		
func save_sector():
	var sector = SectorResource.new();
	for i in get_tree().get_nodes_in_group("brick"):
		var brick := i as BrickPreview;
		var properties = {
			"position": brick.global_position,
			"resource": brick.resource,
		};
		
		sector.bricks += [properties];
	
	var data_directory = Directory.new();
	data_directory.open("user://");
	if !data_directory.dir_exists("sectors"):
		data_directory.make_dir("sectors");
	
	ResourceSaver.save("user://sectors/" + game_data.sector_name + ".res", sector);
	game_data.setup_custom_game(game_data.sector_name, sector);
