extends CanvasLayer

onready var game_data := $"/root/game_data" as GameData;

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused;
		visible = !visible;
		if game_data.game_mode == game_data.game_modes.custom:
			$Warning.visible = false;
