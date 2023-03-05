shader_type canvas_item;

uniform vec2 redOffset = vec2(10, 10);
uniform vec2 blueOffset = vec2(-10, -10);

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	color.r = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE * redOffset), 0.0).r;
	color.g = texture(SCREEN_TEXTURE, SCREEN_UV, 0.0).g;
	color.b = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE * blueOffset), 0.0).b;
	
	COLOR = color;
}