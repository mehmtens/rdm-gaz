extends Node
## Menü sesleri (tur 243): her düğme odakta tık, basışta seçim sesi çalar;
## düğmenin kendi sesi (coin/ret) aynı karede çaldıysa genel seçim sesi susar.


func _ready() -> void:
	for n in [&"ui_move", &"ui_select", &"ui_deny"]:
		assert(Sfx._streams.has(n), "ses yüklenmedi: %s" % n)

	var a := Button.new()
	var b := Button.new()
	add_child(a)
	add_child(b)
	await get_tree().process_frame

	## Odak değişimi → tık (sessizlik penceresi geçtikten sonra).
	await get_tree().create_timer(0.2).timeout
	Sfx.last_played = &""
	b.grab_focus()
	assert(Sfx.last_played == &"ui_move", "odak tıkı yok: %s" % Sfx.last_played)

	## Hemen arkasından gelen programatik odak yutulur (çift tık yok).
	Sfx.last_played = &""
	a.grab_focus()
	assert(Sfx.last_played == &"", "sessizlik penceresi çalışmıyor")

	## Basış → kare sonunda seçim sesi.
	Sfx.last_played = &""
	a.pressed.emit()
	assert(Sfx.last_played == &"", "seçim sesi kare sonuna ertelenmeli")
	await get_tree().process_frame
	assert(Sfx.last_played == &"ui_select", "seçim sesi yok: %s" % Sfx.last_played)

	## Düğme kendi sesini çalarsa (yetersiz coin) seçim sesi susar.
	b.pressed.connect(func() -> void: Sfx.play(&"ui_deny"))
	Sfx.last_played = &""
	b.pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	assert(Sfx.last_played == &"ui_deny", "ret sesinin üstüne seçim bindi: %s" % Sfx.last_played)

	## sfx_quiet meta'lı düğme sessiz.
	var q := Button.new()
	q.set_meta(Sfx.QUIET_META, true)
	add_child(q)
	await get_tree().create_timer(0.2).timeout
	Sfx.last_played = &""
	q.grab_focus()
	q.pressed.emit()
	await get_tree().process_frame
	assert(Sfx.last_played == &"", "sessiz düğme ses çaldı")

	## Dokunmatik düğmeler (TouchScreenButton) BaseButton değil: kancaya girmez.
	print("UI SFX OK")
	get_tree().quit(0)
