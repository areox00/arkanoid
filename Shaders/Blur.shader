shader_type canvas_item;

uniform float amount = 3.0;

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV, 3.0);
}