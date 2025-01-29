shader_type spatial;
render_mode blend_mix,
    cull_disabled,
    depth_prepass_alpha,
    shadows_disabled,
    specular_disabled,
    vertex_lighting;

uniform bool affine_mapping = false;
uniform sampler2D albedo : source_color, filter_nearest;
uniform float alpha_scissor : hint_range(0, 1) = 0.5;
uniform float jitter: hint_range(0, 1) = 0.25;
uniform ivec2 resolution = ivec2(320, 240);

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// Shine effect uniforms
uniform bool is_shining = false;
uniform vec4 shine_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float cycle_interval : hint_range(0.5, 5.0) = 1.0;
uniform float shine_speed : hint_range(1.0, 5.0) = 3.0;
uniform float shine_width : hint_range(1.0, 100.0) = 3.0;

vec4 snap_to_position(vec4 base_position)
{
    vec4 snapped_position = base_position;
    snapped_position.xyz = base_position.xyz / base_position.w;
    
    vec2 snap_resolution = floor(vec2(resolution) * (1.0 - jitter));
    snapped_position.x = floor(snap_resolution.x * snapped_position.x) / snap_resolution.x;
    snapped_position.y = floor(snap_resolution.y * snapped_position.y) / snap_resolution.y;
    
    snapped_position.xyz *= base_position.w;
    return snapped_position;
}

void vertex()
{
    vec4 snapped_position = snap_to_position(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
    if (affine_mapping)
    {
        POSITION = snapped_position;
        POSITION /= abs(POSITION.w);
    }
    else
    {
        POSITION = snapped_position;
    }
}

void fragment()
{
    vec4 color_base = COLOR;
    vec4 texture_color = texture(albedo, UV);
    vec4 prev_pass_color = texture(screen_texture, SCREEN_UV);
    vec4 final_color = mix(prev_pass_color, color_base * texture_color, texture_color.a);

    if (is_shining)
    {
        vec3 vertex = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
        float width = shine_width * 0.001 * cycle_interval;
        float frequency = floor(sin(vertex.z * cycle_interval + TIME * shine_speed * cycle_interval) + width);
        float shine_alpha = clamp((1.0 - dot(NORMAL, VIEW)) * frequency * shine_color.a, 0.0, 1.0);
        final_color.rgb = mix(final_color.rgb, shine_color.rgb, shine_alpha);
    }

    ALBEDO = vec3(0.0);
	SPECULAR = 0.0;
    EMISSION = final_color.rgb;
    ALPHA = final_color.a;
    ALPHA_SCISSOR_THRESHOLD = alpha_scissor;
}
