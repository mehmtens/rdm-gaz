shader_type canvas_item;

varying vec2 local_pos;

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	float top = smoothstep(-620.0, -500.0, local_pos.y);
	float left = smoothstep(-960.0, -820.0, local_pos.x);
	float right = 1.0 - smoothstep(820.0, 960.0, local_pos.x);
	COLOR.a *= top * left * right;
}
