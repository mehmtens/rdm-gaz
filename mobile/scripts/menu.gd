## Menu — başlık ekranı: kayan şehir arka planı, animasyonlu Redmount ve rakipler, OYNA.
extends Control

const GOLD := Color(1, 0.84, 0.3)

var _bg: Array[Sprite2D] = []
var _t := 0.0


func _ready() -> void:
	Music.play("menu")
	var bg_layer := Node2D.new()
	add_child(bg_layer)
	var tex: Texture2D = load("res://art/bg/urban_dusk.png")
	for i in 3:
		var s := Sprite2D.new()
		s.texture = tex
		s.centered = false
		s.flip_h = i % 2 == 1
		bg_layer.add_child(s)
		_bg.append(s)
	var shade := ColorRect.new()
	shade.color = Color(0.04, 0.02, 0.08, 0.35)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	# Sahne: Redmount solda, eşkıya ve bıçaklı ajan sağda karşı karşıya.
	var hero := SpriteLib.make_sprite("redmount", Player.ANIMS)
	hero.play("idle")
	hero.set_meta("anchor", Vector2(0.24, 0.93))
	hero.scale = Vector2(1.5, 1.5)
	add_child(hero)
	var foes: Array = []
	for k in [["thug", 0.74], ["knife", 0.86]]:
		var d: Dictionary = Enemy.TYPES[k[0]]
		var e := SpriteLib.make_sprite(d["char"], d["anims"])
		e.play("idle")
		e.flip_h = true
		e.scale = Vector2(1.25, 1.25)
		e.set_meta("anchor", Vector2(k[1], 0.93))
		add_child(e)
		foes.append(e)

	var title := Label.new()
	title.text = "REDMOUNT"
	title.add_theme_font_size_override("font_size", 132)
	title.add_theme_color_override("font_color", Color(0.95, 0.22, 0.18))
	title.add_theme_color_override("font_outline_color", Color(0.05, 0.02, 0.06))
	title.add_theme_constant_override("outline_size", 28)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	title.add_theme_constant_override("shadow_offset_y", 10)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.size = Vector2(1000, 160)
	title.position = Vector2(-500, 40)
	add_child(title)
	var sub := Label.new()
	sub.text = "S O K A K L A R"
	sub.add_theme_font_size_override("font_size", 40)
	sub.add_theme_color_override("font_color", GOLD)
	sub.add_theme_color_override("font_outline_color", Color(0.05, 0.02, 0.06))
	sub.add_theme_constant_override("outline_size", 10)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.set_anchors_preset(Control.PRESET_CENTER_TOP)
	sub.size = Vector2(1000, 60)
	sub.position = Vector2(-500, 190)
	add_child(sub)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.position = Vector2(-210, 0)
	box.add_theme_constant_override("separation", 16)
	add_child(box)
	var play := _button("OYNA", true)
	play.pressed.connect(func():
		Sfx.play("powerup")
		Game.start_level(0))
	box.add_child(play)
	var best: Dictionary = Game.best.get("L01", {})
	var info := Label.new()
	info.text = "%s   ·   Cüzdan: %d coin" % [_stars(int(best.get("stars", 0))), Game.wallet]
	info.add_theme_font_size_override("font_size", 30)
	info.add_theme_color_override("font_color", GOLD)
	info.add_theme_color_override("font_outline_color", Color(0.05, 0.02, 0.06))
	info.add_theme_constant_override("outline_size", 8)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(info)
	play.grab_focus()
	_layout()
	get_viewport().size_changed.connect(_layout)


func _stars(n: int) -> String:
	return "★".repeat(n) + "☆".repeat(3 - n)


func _button(text: String, primary: bool) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(420, 100)
	b.add_theme_font_size_override("font_size", 48)
	var bgc := Color(0.78, 0.2, 0.16) if primary else Color(0.16, 0.11, 0.2)
	b.add_theme_stylebox_override("normal", Hud._box(bgc, GOLD, 5, 18))
	b.add_theme_stylebox_override("hover", Hud._box(bgc.lightened(0.12), GOLD, 5, 18))
	b.add_theme_stylebox_override("pressed", Hud._box(bgc.darkened(0.2), GOLD, 5, 18))
	b.add_theme_stylebox_override("focus", Hud._box(Color(0, 0, 0, 0), Color.WHITE, 3, 18))
	return b


func _layout() -> void:
	var vp := get_viewport_rect().size
	for c in get_children():
		if c is AnimatedSprite2D and c.has_meta("anchor"):
			var a: Vector2 = c.get_meta("anchor")
			c.position = Vector2(vp.x * a.x, vp.y * a.y)


func _process(dt: float) -> void:
	_t += dt
	var vp := get_viewport_rect().size
	var sc := vp.y / _bg[0].texture.get_height() * 1.05
	var w := _bg[0].texture.get_width() * sc
	var ox := -fposmod(_t * 25.0, w * 2.0)
	for i in _bg.size():
		_bg[i].scale = Vector2(sc, sc)
		_bg[i].position = Vector2(ox + i * w, 0)
