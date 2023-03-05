extends CanvasLayer

onready var game_data := $"/root/game_data" as GameData;

# Misc
func reload_list():
	$"%SectorsList".clear();
	
	var n := 0;
	var dir := Directory.new();
	var error = dir.open("user://sectors");
	if error == OK:
		dir.list_dir_begin();
		var file_name = dir.get_next();
		while file_name != "":
			if !dir.current_is_dir():
				$"%SectorsList".add_item(file_name);
				$"%SectorsList".set_item_tooltip_enabled(n, false);
				n += 1;
			file_name = dir.get_next();
	else:
		anim_open_error("Cannot open sectors folder, error code: " + str(error));

# Title buttons callbacks
func new_game():
	game_data.setup_story_game();
	game_data.continue_game = false;
	get_tree().change_scene("res://Scenes/States/Gameplay.tscn");

func load_game():
	game_data.setup_story_game();
	game_data.continue_game = true;
	get_tree().change_scene("res://Scenes/States/Gameplay.tscn");

func editor():
	anim_fade_in($"%List");
	anim_move_to($"%TitleButtons", Vector2.LEFT * 360);
	reload_list();

func quit():
	get_tree().quit(0);

# Editor buttons callbacks
func list_play():
	var items := $"%SectorsList".get_selected_items() as PoolIntArray;
	if items.empty():
		return;

	var file := $"%SectorsList".get_item_text(items[0]) as String;

	if file.is_valid_filename():
		var loaded = load("user://sectors/" + file) as SectorResource;
		if loaded:
			game_data.setup_custom_game(file.get_basename(), loaded);
			get_tree().change_scene("res://Scenes/States/Gameplay.tscn");
		else:
			anim_open_error("Cannot open file, possible corruption");
			anim_shake($"%ListButtons");
	else:
		anim_open_error("Cannot open file");
		anim_shake($"%ListButtons");
	
func list_edit():
	var items := $"%SectorsList".get_selected_items() as PoolIntArray;
	if items.empty():
		return;

	var file := $"%SectorsList".get_item_text(items[0]) as String;

	if file.is_valid_filename():
		var loaded = load("user://sectors/" + file) as SectorResource;
		if loaded:
			game_data.sector_name = file;
			game_data.sector_resource = loaded
			get_tree().change_scene("res://Scenes/States/Editor.tscn");
		else:
			anim_open_error("Cannot open file, possible corruption");
			anim_shake($"%ListButtons");
	else:
		anim_open_error("Cannot open file");
		anim_shake($"%ListButtons");
	
func list_add():
	anim_fade_in($"%Prompt");
	anim_darken($"%List");
	$"%PromptBlocker".visible = true;
	
func list_remove():
	var items := $"%SectorsList".get_selected_items() as PoolIntArray;
	if !items.empty() and $"%SectorsList".get_item_text(items[0]).is_valid_filename():
		var dir := Directory.new();
		var error = dir.remove("user://sectors/" + $"%SectorsList".get_item_text(items[0]));
		if error:
			anim_open_error("Cannot remove item, error code: " + str(error));
			anim_shake($"%ListButtons");
		else:
			reload_list();
	
	
func list_back():
	anim_fade_out($"%List");
	anim_move_to($"%TitleButtons", Vector2.ZERO);

# Prompt buttons ballbacks
func prompt_done():
	var sector = SectorResource.new();
	
	var data_directory = Directory.new();
	data_directory.open("user://");
	if !data_directory.dir_exists("sectors"):
		var error = data_directory.make_dir("sectors");
		if error:
			anim_open_error("Cannot create sectors directory, error code: " + str(error));
			return;
		
	var sector_name := ($"%PromptEdit".text as String);
	
	if sector_name.is_valid_filename() and sector_name.length() > 0:
		var error := ResourceSaver.save("user://sectors/" + sector_name + ".res", sector);
		if error != OK:
			anim_open_error("Cannot create file, error code: " + str(error));
			anim_shake($"%Prompt");
		else:
			anim_fade_out($"%Prompt");
			anim_fade_in($"%List");
			$"%PromptBlocker".visible = false;
			reload_list();
	else:
		anim_open_error("Invalid name (too short or contains illegal character)");
		anim_shake($"%Prompt");
	
func prompt_cancel():
	anim_fade_out($"%Prompt");
	anim_fade_in($"%List");
	$"%PromptBlocker".visible = false;

func _ready():
	# Title buttons
	$"%NewGame".connect("pressed", self, "new_game");
	$"%LoadGame".connect("pressed", self, "load_game");
	$"%Editor".connect("pressed", self, "editor");
	$"%Quit".connect("pressed", self, "quit");

	# List buttons
	$"%ListPlay".connect("pressed", self, "list_play");
	$"%ListEdit".connect("pressed", self, "list_edit");
	$"%ListAdd".connect("pressed", self, "list_add");
	$"%ListRemove".connect("pressed", self, "list_remove");
	$"%ListBack".connect("pressed", self, "list_back");

	# Prompt buttons
	$"%PromptDone".connect("pressed", self, "prompt_done");
	$"%PromptCancel".connect("pressed", self, "prompt_cancel");
	
	var directory = Directory.new();
	var save_exists = directory.file_exists("user://game_state.res");
	
	if !save_exists:
		$"%LoadGame".disabled = true;
	else:
		$"%LoadGame".disabled = false;

# Animations
func anim_shake(node: Control):
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN);
	tween.tween_property(node.get_parent(), "position:x", -10.0, 0.1);
	tween.tween_property(node.get_parent(), "position:x", 10.0, 0.1);
	tween.tween_property(node.get_parent(), "position:x", 0.0, 0.1);

func anim_instant_show(node: Control):
	node.visible = true;
	node.modulate.a = 1.0;

func anim_fade_in(node: Control):
	node.visible = true;
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT);
	tween.tween_property(node, "modulate:a", 1.0, 0.25);

func anim_fade_out(node: Control):
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT);
	tween.tween_property(node, "modulate:a", 0.0, 0.25);
	tween.connect("finished", node, "set_visible", [false]);

func anim_open_error(text: String):
	anim_instant_show($"%Error");
	$"%ErrorLabel".text = text;
	anim_long_fade_out($"%Error", true);

var long_tween: SceneTreeTween;
func anim_long_fade_out(node: Control, kill: bool):
	if long_tween and kill:
		long_tween.kill();
	long_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN);
	long_tween.tween_property(node, "modulate:a", 0.0, 2.0);
	long_tween.connect("finished", node, "set_visible", [false]);

func anim_move_to(node: Control, position: Vector2):
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT);
	tween.tween_property(node, "rect_position", position, 0.25);

func anim_darken(node: Control):
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT);
	tween.tween_property(node, "modulate:a", 0.25, 0.25);
