## Piksel TTF ilerleme genişlikleri: Türkçe ekli kesme işareti ("GAZELLE'İN")
## ve dar İ/I/i/ı/l kelime arası boşluk gibi okunmamalı.
##   godot --headless --path . res://tests/font_metrics.tscn  -> "FONT METRICS: PASS"
extends Node


func _ready() -> void:
	var font: Font = load("res://assets/ui/redmount_pixel.ttf")
	var w := func(s: String) -> float:
		return font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
	var ok := true
	## Kesme işareti boşluktan dar olmalı; yoksa ek ayrı kelime gibi durur.
	if w.call("'") >= w.call(" "):
		push_error("kesme işareti boşluktan dar değil: %s >= %s" % [w.call("'"), w.call(" ")])
		ok = false
	## Kesmeli ek, boşluklu yazımdan belirgin kısa kalmalı.
	if w.call("E'İN") >= w.call("E İN"):
		push_error("E'İN boşluklu yazımdan kısa değil")
		ok = false
	for ch in ["İ", "I", "i", "ı", "l"]:
		if w.call(ch) >= w.call("A"):
			push_error("%s dar değil" % ch)
			ok = false
	print("FONT METRICS: ", "PASS" if ok else "FAIL")
	get_tree().quit(0 if ok else 1)
