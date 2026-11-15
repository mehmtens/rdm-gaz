## Mağaza kartı etki sayısı satır sonunda bölünmez ("+" / "%8" kopması, tur 200).
##  godot --headless --path . res://tests/shop_stat_wrap.tscn → "SHOP STAT WRAP: PASS"
extends Node

const ShopMenuScript := preload("res://scripts/ui/shop_menu.gd")


func _ready() -> void:
	var ok := true
	var g: String = ShopMenuScript._glue_stat("Adının rengi. Yumruk hasarı +%8")
	ok = ok and g == "Adının rengi. Yumruk hasarı +⁠%8"
	ok = ok and ShopMenuScript._glue_stat("Azami can +10").ends_with("can +10")
	ok = ok and ShopMenuScript._glue_stat("Topladığın coin 2 kat sayılır.") == "Topladığın coin 2 kat sayılır."
	# Dar etikette hiçbir satır "+"/"%" ile başlayıp "+" ile bitmemeli (gerçek satır kırma).
	var font: Font = PixelUI.font()
	for wi in range(120, 420, 2):
		var w := float(wi)
		var para := TextParagraph.new()
		para.add_string(g, font, PixelUI.MIN_SIZE)
		para.width = w
		para.break_flags = TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE
		for i in para.get_line_count():
			var r: Vector2i = para.get_line_range(i)
			var line := g.substr(r.x, r.y - r.x).strip_edges()
			if line.begins_with("%") or line.begins_with("+") or line.ends_with("+") or line.begins_with("⁠"):
				print("kopuk satır @%d: '%s'" % [int(w), line])
				ok = false
	print("SHOP STAT WRAP: %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit(0 if ok else 1)
