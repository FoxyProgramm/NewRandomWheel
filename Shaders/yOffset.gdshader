shader_type canvas_item;

uniform float y_offset:hint_range(-64.0, 64.0, 0.01);

void vertex() {
	VERTEX.y += y_offset;
}

void fragment() {
}