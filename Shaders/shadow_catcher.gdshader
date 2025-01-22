shader_type spatial;

render_mode shadow_to_opacity, blend_mul;

void fragment(){
	ALBEDO = vec3(1.0);
}

void light() {
	// unshaded lighting
	DIFFUSE_LIGHT = vec3(ATTENUATION*100.0+5.0);
	// add alpha based on attenuation, which includes if we're in shadow, cap at our max opacity
	ALPHA = 1.0;
}