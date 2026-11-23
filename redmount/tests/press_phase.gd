extends Node
## Pres fazları periyodun kesridir (crusher.gd: _t = phase_offset * period).
## 1.0 ve üstü değerler sessizce 0'a sarar ve kademeli pres hattını eşzamanlı
## yapar (Bölüm 22, tur 384). Bölüm betiklerindeki tüm `_press(...)` ve
## `_press_gantry(...)` faz değerleri [0, 1) aralığında olmalı.

func _ready() -> void:
	var bad := PackedStringArray()
	var press := RegEx.create_from_string(r"_press\(\s*[-0-9.]+\s*,\s*([-0-9.]+)")
	var gantry := RegEx.create_from_string(r"_press_gantry\(\s*\[[^\]]*\]\s*,\s*\[([^\]]*)\]")
	var n := 0
	var dir := DirAccess.open("res://scripts/systems")
	for f in dir.get_files():
		if not (f.begins_with("bolum") and f.ends_with(".gd")):
			continue
		var src := FileAccess.get_file_as_string("res://scripts/systems/" + f)
		for m in press.search_all(src):
			n += 1
			var p := float(m.get_string(1))
			if p < 0.0 or p >= 1.0:
				bad.append("%s faz %s" % [f, m.get_string(1)])
		for m in gantry.search_all(src):
			for s in m.get_string(1).split(","):
				n += 1
				var p := float(s.strip_edges())
				if p < 0.0 or p >= 1.0:
					bad.append("%s portal faz %s" % [f, s.strip_edges()])
	if n == 0:
		print("PRESS PHASE: FAIL (hiç pres bulunamadı)")
	elif bad.is_empty():
		print("PRESS PHASE: PASS (%d faz)" % n)
	else:
		print("PRESS PHASE: FAIL ", bad)
	get_tree().quit(0 if bad.is_empty() and n > 0 else 1)
