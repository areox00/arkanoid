shader_type canvas_item;

uniform sampler2D gradient;

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	if (pixel.a > 0.5) {
		COLOR = mix(pixel, texture(gradient, UV), 0.5);
	}
	else {
		COLOR = vec4(0.0);
	}
}