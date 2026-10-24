// Redmount kostümü: aynı sprite sayfaları, giysinin palet takası.
// Ceket/pantolon/tişört doygunluğu düşük koyu-gri piksellerdir; parlaklıkları
// kostümün koyu→açık rampasına eşlenir. Kontur (çok koyu), ten/saç (doygun) ve
// beyaz ayakkabı/göz (açık) olduğu gibi kalır. Gece sahnesinde dark_rim'in
// konturu da burada çizilir (oyuncu rig'inde tek malzeme olabildiği için).
// Pantolon pikselleri sayfada alfa 254 ile işaretlidir (tools/gen_costume_mask.py);
// onlar ikinci rampaya (pants_shade → pants_light) eşlenir, ceket ilk rampada kalır.
// Başlığın tepesinden taşan saç pikselleri alfa 255 - 2·bitler ile işaretlidir
// (tools/gen_costume_accessory.py); `hair_bit` o kostümün başlığının bitidir, işaretli
// piksel saydam sayılır (konturda da), böylece saç şapkayı delip çıkmaz.
shader_type canvas_item;

uniform vec4 shade : source_color = vec4(0.04, 0.07, 0.19, 1.0);
uniform vec4 light : source_color = vec4(0.27, 0.43, 0.71, 1.0);
uniform vec4 pants_shade : source_color = vec4(0.04, 0.07, 0.19, 1.0);
uniform vec4 pants_light : source_color = vec4(0.27, 0.43, 0.71, 1.0);
uniform bool rim_enabled = false;
uniform vec4 rim_color : source_color = vec4(1.0, 0.82, 0.52, 0.9);
uniform float rim_width = 3.0;
uniform int hair_bit = 0;

varying vec4 tint;

void vertex() {
	tint = COLOR;
}

// Pikselin işaret kodu: 255 - alfa (0 işaretsiz, 1 pantolon, çift = saç bitleri × 2).
int mark_of(float a) {
	return int(round((1.0 - a) * 255.0));
}

bool hidden_hair(float a) {
	int code = mark_of(a);
	return hair_bit != 0 && code >= 2 && code <= 14 && code % 2 == 0 && ((code / 2) & hair_bit) != 0;
}

// Konturda komşu piksel: gizli saç saydam sayılır (TEXTURE yalnız fragment'ta okunur).
float solid(float a) {
	return (a >= 0.5 && !hidden_hair(a)) ? 1.0 : 0.0;
}

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	if (c.a < 0.5 || hidden_hair(c.a)) {
		COLOR = vec4(0.0);
		if (rim_enabled) {
			vec2 d = TEXTURE_PIXEL_SIZE * rim_width;
			float a = 0.0;
			a = max(a, solid(texture(TEXTURE, UV + vec2(d.x, 0.0)).a));
			a = max(a, solid(texture(TEXTURE, UV - vec2(d.x, 0.0)).a));
			a = max(a, solid(texture(TEXTURE, UV + vec2(0.0, d.y)).a));
			a = max(a, solid(texture(TEXTURE, UV - vec2(0.0, d.y)).a));
			if (a >= 0.5) {
				COLOR = rim_color * tint;
			}
		}
	} else {
		bool pants = mark_of(c.a) == 1;
		c.a = 1.0;
		float mx = max(c.r, max(c.g, c.b));
		float mn = min(c.r, min(c.g, c.b));
		float sat = mx > 0.0 ? (mx - mn) / mx : 0.0;
		if (sat < 0.25) {
			float w = smoothstep(0.035, 0.07, mx) * (1.0 - smoothstep(0.5, 0.62, mx));
			vec3 lo = pants ? pants_shade.rgb : shade.rgb;
			vec3 hi = pants ? pants_light.rgb : light.rgb;
			vec3 ramp = mix(lo, hi, smoothstep(0.03, 0.45, mx));
			c.rgb = mix(c.rgb, ramp, w);
		}
		COLOR = c * tint;
	}
}
