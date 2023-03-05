extends Button
class_name HoverAnimation

var tween: SceneTreeTween;

var toggled := false;

func _ready():
	self.connect("mouse_entered", self, "play_open");
	self.connect("mouse_exited", self, "play_close");
	self.connect("toggled", self, "toggle");

func toggle(button_pressed: bool):
	toggled = button_pressed;
	if !toggled:
		play_close();

func play_open():
	if !disabled:
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT);
		tween.tween_property(self, "margin_left", 15.0, 0.10);

func play_close():
	if !toggled and !disabled:
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT);
		tween.tween_property(self, "margin_left", 0.0, 0.10);
