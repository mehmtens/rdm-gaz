## SpriteLib — 200x240 animasyon şeritlerinden SpriteFrames kurar ve önbellekler.
## Tüm şeritlerde ayak çizgisi y=234; ofset bunu düğüm orijinine oturtur.
class_name SpriteLib
extends RefCounted

const FRAME := Vector2i(200, 240)
const FEET_OFFSET := Vector2(0, -114) ## centered sprite: 120 - 234

static var _cache: Dictionary = {}
static var _flash_shader: Shader


## defs: anim -> [dosya, fps, döngü, (opsiyonel kare listesi)]
static func frames(character: String, defs: Dictionary) -> SpriteFrames:
	if _cache.has(character):
		return _cache[character]
	var sf := SpriteFrames.new()
	sf.remove_animation(&"default")
	for anim in defs:
		var d: Array = defs[anim]
		var tex: Texture2D = load("res://art/chars/%s/%s.png" % [character, d[0]])
		var count := tex.get_width() / FRAME.x
		var idx: Array = d[3] if d.size() > 3 else range(count)
		sf.add_animation(anim)
		sf.set_animation_speed(anim, float(d[1]))
		sf.set_animation_loop(anim, bool(d[2]))
		for i in idx:
			var at := AtlasTexture.new()
			at.atlas = tex
			at.region = Rect2(int(i) * FRAME.x, 0, FRAME.x, FRAME.y)
			sf.add_frame(anim, at)
	_cache[character] = sf
	return sf


static func make_sprite(character: String, defs: Dictionary) -> AnimatedSprite2D:
	var s := AnimatedSprite2D.new()
	s.sprite_frames = frames(character, defs)
	s.offset = FEET_OFFSET
	s.material = flash_material()
	return s


## Beyaz vuruş parlaması için karakter başına materyal (uniform "flash" 0..1).
static func flash_material() -> ShaderMaterial:
	if _flash_shader == null:
		_flash_shader = Shader.new()
		_flash_shader.code = "shader_type canvas_item;\n" \
			+ "uniform float flash : hint_range(0.0, 1.0) = 0.0;\n" \
			+ "uniform vec4 tint : source_color = vec4(1.0);\n" \
			+ "void fragment() {\n" \
			+ "\tvec4 c = texture(TEXTURE, UV) * COLOR;\n" \
			+ "\tCOLOR = vec4(mix(c.rgb * tint.rgb, vec3(1.0), flash), c.a);\n" \
			+ "}\n"
	var m := ShaderMaterial.new()
	m.shader = _flash_shader
	return m
