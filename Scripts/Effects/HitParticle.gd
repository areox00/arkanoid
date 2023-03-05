extends Particles2D

func _ready():
	self.emitting = true;
	var time = self.lifetime / self.speed_scale;
	get_tree().create_timer(time).connect("timeout", self, "queue_free");
