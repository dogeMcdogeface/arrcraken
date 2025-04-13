shader_type canvas_item;

uniform sampler2D normal_map; // The 20x20 normal map
uniform vec2 texture_size = vec2(20.0, 20.0); // Size of the input texture

void fragment() {
    vec2 uv = UV;

    // Map UV to which cell
    vec2 cell_uv = uv * texture_size;
    ivec2 cell_id = ivec2(floor(cell_uv));
    vec2 local_uv = fract(cell_uv);

    // Get normal map data
    vec2 texel_coord = (vec2(cell_id) + 0.5) / texture_size;
    vec4 normal_data = texture(normal_map, texel_coord);

    float red = normal_data.r;   // Line length
    float green = normal_data.g; // Rotation (0-1)

    float angle = green * 6.28318530718; // radians
    float line_length = red * 0.9;

    // Centered coordinates (-0.5 to 0.5)
    vec2 centered = local_uv - 0.5;

    // Rotate local UV so line is always in +X direction
    float s = sin(-angle);
    float c = cos(-angle);
    vec2 rotated = vec2(centered.x * c - centered.y * s, centered.x * s + centered.y * c);

    // Draw one-sided line starting at center, going to +X
    float line_width = 0.02;

    // From center (0,0) to line_length in +X
    bool inside_length = rotated.x >= 0.0 && rotated.x <= line_length;
    bool inside_width = abs(rotated.y) < line_width;

    if (inside_length && inside_width) {
        COLOR = vec4(1.0);
    } else {
        COLOR = vec4(0.0);
    }
}
