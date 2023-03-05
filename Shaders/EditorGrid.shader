shader_type canvas_item;

uniform float columns = 10;
uniform float rows = 10;

void fragment() {
	float border_size = 0.05;
	float border_size_bold = 0.06;
	float snap_size = 20.0;
	
	// Hardcoded values, consider passing them via uniform
	vec2 grid_size = vec2(1080.0 / snap_size, 880.0 / snap_size);
	float offset = border_size / 2.0;
	float offset_bold = border_size_bold / 2.0;
	
	COLOR = vec4(1.0, 1.0, 1.0, 0.0);
	
	if (mod(UV.x * grid_size.x + offset_bold, 9.0) < border_size_bold || mod(UV.y * grid_size.y + offset_bold, 8.0) < border_size_bold) {
		COLOR.a = 0.2;
	}
	else if (mod(UV.x * grid_size.x + offset, 1.0) < border_size || mod(UV.y * grid_size.y + offset, 1.0) < border_size) {
		COLOR.a = 0.1;
	}
}
