shader_type canvas_item;

uniform float rows;
uniform float columns;

uniform sampler2D gradient_h;
uniform sampler2D gradient_v;
uniform sampler2D grid_texture;
uniform vec4 hit_color : hint_color;
uniform float hit_mix;
uniform float explosion_progress = 1.0;

vec2 grid(vec2 uv) {
	return fract(vec2(uv.x, uv.y));
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	//vec2 grid = grid(UV + vec2(-0.25, -0.25) * TIME) * texture(gradient, UV).rg;
	//vec2 grid = grid(texture(uv_gradient, UV).rg + vec2(-0, -0.1) * TIME) * texture(gradient, UV).rg;
	//COLOR.rgb = vec3(grid.rg, 0.0);
	
	vec2 grid_color = grid(texture(grid_texture, UV).rg * vec2(columns, rows) + vec2(-0, -0.1) * TIME) * texture(gradient_v, UV).rg * texture(gradient_h, UV).rg;
		
	vec3 final_color = vec3(grid_color.rg, 0.0) * 0.5 * color.rgb;
	float brightness = (final_color.r + final_color.g + final_color.b) / 3.0;
	vec3 grayscale = vec3(brightness, brightness, brightness);
			
	vec3 base = grayscale.rgb; vec3 blend = color.rgb;
			
	COLOR.rgb = mix(base / (1.0 - blend * 0.80), hit_color.rgb, hit_mix);
	
	if (explosion_progress < 1.0) {
		vec2 uv = grid(UV * vec2(50, 50));
		//COLOR.rgb = vec3(uv, 0.0);
		float dist = distance(uv, vec2(0.5, 0.5));
		//COLOR.rgb = vec3(dist, 0.0, 0.0);

		COLOR.a *= step(dist, explosion_progress);
	}
	
	if (color.a < 0.1) {
		COLOR.a = 0.0;
	}
	
	//COLOR = vec4(UV.rg + texture(TEXTURE, UV).rg, 0.0, 1.0);
	//COLOR = texture(uv_gradient, UV);
}
