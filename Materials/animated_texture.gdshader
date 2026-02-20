shader_type spatial;
uniform sampler2D albedo_texture;
uniform float rows = 4.0;
uniform float columns = 4.0;
uniform float fps = 12.0;

void fragment() {
    // Calculate frame index
    float frame = floor(TIME * fps);
    float row = floor(frame / columns);
    float col = mod(frame, columns);

    // Adjust UV
    vec2 frame_uv = UV / vec2(columns, rows);
    frame_uv.x += col / columns;
    frame_uv.y += row / rows;

    vec4 text = texture(albedo_texture, frame_uv);
    ALBEDO = text.rgb;
}