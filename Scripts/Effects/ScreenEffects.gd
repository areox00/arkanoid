extends Node
class_name ScreenEffects

onready var ca = $ChromaticAbberation as ColorRect; 

func abberation_on():
	ca.get_material().set_shader_param("redOffset", Vector2(20, 0));
	ca.get_material().set_shader_param("blueOffset", Vector2(-20, 0));

func abberation_off():
	var tween := create_tween().set_trans(Tween.TRANS_ELASTIC);
	tween.tween_property(ca.get_material(), "shader_param/redOffset", Vector2.ZERO, 0.3);
	tween.parallel().tween_property(ca.get_material(), "shader_param/blueOffset", Vector2.ZERO, 0.3);
