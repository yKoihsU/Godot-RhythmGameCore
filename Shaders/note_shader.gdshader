shader_type canvas_item;

uniform vec4 base_color: source_color;
uniform float pulse_intensity : hint_range(0, 1) = 0.0;
uniform float dissolve_amount : hint_range(0, 1) = 0.0;

void fragment(){
	vec4 color = base_color;
	vec4 white_color = vec4(1.0);

	color.rgb += vec3(pulse_intensity) * abs(sin(TIME * 20.0)) * 0.1;

	if (dissolve_amount > 0.0){
		if (UV.y > dissolve_amount){
			discard;
		}
	}

	COLOR *= color / white_color;
}