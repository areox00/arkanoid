extends CanvasLayer
class_name TransitionSector

onready var transition_scene := load("res://Scenes/Transitions/TransitionSector.tscn");

func set_text(text: String):
	($Modulate as CanvasModulate).color.a = 1.0;
	($Sector as Label).text = text;

func play():
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT);
	tween.tween_property($Modulate, "color:a", 0.0, 2.0);
	yield(tween, "finished");
