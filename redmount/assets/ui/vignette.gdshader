shader_type canvas_item;

// Ekran kenarlarını hafifçe karartan vinyet (Görev 17).
uniform float strength : hint_range(0.0, 1.0) = 0.5;
uniform vec4 tint : source_color = vec4(0.0, 0.0, 0.04, 1.0);

void fragment() {
	vec2 uv = SCREEN_UV - 0.5;
	float d = length(uv * vec2(1.15, 1.0)) * 1.4;
	float v = smoothstep(0.5, 1.0, d) * strength;
	COLOR = vec4(tint.rgb, v);
}
