extends Node
class_name GameData

enum game_modes {story, custom};

var game_mode: int;
var continue_game: bool;
var sector_name: String;
var sector_resource: SectorResource;

func setup_custom_game(custom_name: String, resource: SectorResource):
	game_mode = game_modes.custom;
	sector_name = custom_name;
	sector_resource = resource;

func setup_story_game():
	game_mode = game_modes.story;
