extends Node
class_name GameUI

var added_scene := load("res://Scenes/UI/AddedPoints.tscn");

onready var score_label := $Score as Label;
onready var sectors = $Sector as Label;
onready var sectors_left = $SectorsLeft as Label;
onready var lives = $Lives as Label;
var tween: SceneTreeTween;

func animate_points(points: int, added_points: int, color: Color):
	var added_label := added_scene.instance() as Label;
	added_label.text = str(added_points);
	added_label.rect_position = Vector2.ZERO;
	added_label.rect_position.y += 50;
	added_label.rect_size = score_label.rect_size;
	added_label.rect_size.x -= 10;
	added_label.modulate = color;
	
	score_label.add_child(added_label);
	
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN);
	tween.tween_property(added_label, "rect_position:y", 10.0, 0.6);
	yield(tween, "finished");
	
	added_label.queue_free();
	score_label.text = str("%09d" % points);
	
	tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN);
	tween.tween_property(score_label, "rect_scale", Vector2(1.15, 1.15), 0.15);
	tween.chain().tween_property(score_label, "rect_scale", Vector2(1.0, 1.0), 0.15);
	yield(tween, "finished");
	
func set_sector(sector: int):
	sectors.text = "Sector " + str(sector);
	sectors_left.text = str(33 - sector) + " left";
	
func set_lives(amount: int):
	lives.text = str(amount) + "x";

func hide_sectors():
	sectors.visible = false;
	sectors_left.visible = false;
