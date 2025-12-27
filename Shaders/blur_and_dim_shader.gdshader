shader_type canvas_item;

uniform float dim_strength: hint_range(0.0, 1.0) = 1.0;
uniform float blur_strength: hint_range(0.0, 5.0) = 0.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec3 dim_rgb = vec3(1.0) * dim_strength;
	vec4 blur = texture(SCREEN_TEXTURE, SCREEN_UV, blur_strength);
	
	COLOR = blur;
	COLOR.rgb *= dim_rgb;
}
