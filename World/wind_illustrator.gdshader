shader_type canvas_item;

uniform sampler2D normal_map; // The 20x20 normal map
uniform vec2 texture_size = vec2(20.0, 20.0); // Size of the input texture

void fragment() {
    vec2 uv = UV;

    // Map UV to cell
    vec2 cell_uv = uv * texture_size;
    ivec2 cell_id = ivec2(floor(cell_uv));
    vec2 local_uv = fract(cell_uv);

    // Get data from texture
    vec2 texel_coord = (vec2(cell_id) + 0.5) / texture_size;
    vec4 normal_data = texture(normal_map, texel_coord);

    float red = normal_data.r;
    float green = normal_data.g;
    float blue = normal_data.b;

    // Higher precision angle using G + B
    float angle = green * 6.28318530718; // radians
    float line_length = red * 0.9;

    vec2 centered = local_uv - 0.5;

    // Rotate the UV so the line is horizontal in +X direction
    float s = sin(-angle);
    float c = cos(-angle);
    vec2 rotated = vec2(centered.x * c - centered.y * s, centered.x * s + centered.y * c);

    // Line from center to +X
    float line_width = 0.02;
    bool inside_length = rotated.x >= 0.0 && rotated.x <= line_length;
    bool inside_width = abs(rotated.y) < line_width;

    // Dot at center
    float dot_radius = 0.05;
    bool inside_dot = length(centered) < dot_radius;

    if (inside_length && inside_width) {
        COLOR = vec4(1.0); // Line
    } else if (inside_dot) {
        COLOR = vec4(1.0); // Dot
    } else {
        COLOR = vec4(0.0); // Background
    }
}
