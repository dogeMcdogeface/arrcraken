shader_type canvas_item;

uniform sampler2D normal_map;
uniform vec2 texture_size = vec2(20.0, 20.0);
uniform vec2 override_vector = vec2(0.0, 0.0);

void fragment() {
    vec2 uv = UV;

    vec2 cell_uv = uv * texture_size;
    ivec2 cell_id = ivec2(floor(cell_uv));
    vec2 local_uv = fract(cell_uv);

    float angle = 0.0;
    float line_length = 0.0;
    float shear = 0.0;

    if (override_vector.x != 0.0 || override_vector.y != 0.0) {
        angle = atan(override_vector.y, override_vector.x);
        line_length = length(override_vector) * 0.9;
    } else {
        vec2 texel_coord = (vec2(cell_id) + 0.5) / texture_size;
        vec4 normal_data = texture(normal_map, texel_coord);

        float red = normal_data.r;
        float green = normal_data.g;
        float blue = normal_data.b;

        angle = green * 6.28318530718;
        line_length = red * 0.9;

        //shear = mix(-PI, PI, (blue - 0.8) / 0.2);
		shear = -PI + (blue - 0.6) * (PI + PI) / (1. - 0.6);
    }

    vec2 centered = local_uv - 0.5;

    float s = sin(-angle);
    float c = cos(-angle);
    vec2 rotated = vec2(centered.x * c - centered.y * s,
                        centered.x * s + centered.y * c);

    float line_width = 0.02;

    bool inside_length = rotated.x >= 0.0 && rotated.x <= line_length;
    bool inside_width = abs(rotated.y) < line_width;

    float dot_radius = 0.05;
    bool inside_dot = length(centered) < dot_radius;

    // ---- ARC ----

    float arc_radius = line_length * 0.5;
    float radius = length(rotated);

    float arc_angle = atan(rotated.y, rotated.x);

    bool within_radius = abs(radius - arc_radius) < line_width;

    bool within_angle;
    if (shear >= 0.0) {
        within_angle = arc_angle >= 0.0 && arc_angle <= shear / 4.;
    } else {
        within_angle = arc_angle <= 0.0 && arc_angle >= shear / 4.;
    }

    bool inside_arc = within_radius && within_angle;

    if (inside_length && inside_width) {
        COLOR = vec4(1.0);
    } else if (inside_dot) {
        COLOR = vec4(1.0);
    } else if (inside_arc) {
		if(shear >= 0.0){
			COLOR = vec4(1.0, 0.0, 1.0, 1.0);
		}else{
			COLOR = vec4(0.0, 1.0, 0.0, 1.0);
		}
    } else {
        COLOR = vec4(0.0);
    }
}