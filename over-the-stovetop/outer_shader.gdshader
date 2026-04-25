shader_type canvas_item;

// These variables will show up in your Godot Inspector!
uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Default white
uniform float line_thickness : hint_range(0.0, 10.0) = 0.0; // Set to 0 to hide it initially

void fragment() {
	if (line_thickness < 0.1f) {
		COLOR = texture(TEXTURE, UV);
	} else {
		vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
		
		float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
		outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
		outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
		outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
		outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
		outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
		outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
		outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
		outline = min(outline, 1.0);
		
		vec4 color = texture(TEXTURE, UV);
		COLOR = mix(color, line_color, outline - color.a);
	}
}