// Gece sahnelerinde koyu giysili düşmanın silüetini fener ışığıyla ayırır:
// saydam piksel, opak bir komşusu varsa ince bir kontur pikseli olur.
// Bölümün kenar ışığı rengini kullanır (level.gd edge_light). Modülasyon
// (vuruş parlaması, ölüm solması) korunur.
shader_type canvas_item;

uniform vec4 rim_color : source_color = vec4(1.0, 0.78, 0.45, 0.7);
uniform float width = 3.0;

varying vec4 tint;

void vertex() {
	tint = COLOR;
}

void fragment() {
	// COLOR burada zaten doku × modülasyondur; yalnız dokunun saydam pikselleri değişir
	// (ölüm solmasında modülasyon alfası düşse de gövde kontura dönmez).
	if (texture(TEXTURE, UV).a < 0.5) {
		vec2 d = TEXTURE_PIXEL_SIZE * width;
		float a = 0.0;
		a = max(a, texture(TEXTURE, UV + vec2(d.x, 0.0)).a);
		a = max(a, texture(TEXTURE, UV - vec2(d.x, 0.0)).a);
		a = max(a, texture(TEXTURE, UV + vec2(0.0, d.y)).a);
		a = max(a, texture(TEXTURE, UV - vec2(0.0, d.y)).a);
		if (a >= 0.5) {
			COLOR = rim_color * tint;
		}
	}
}
