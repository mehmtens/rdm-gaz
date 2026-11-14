extends Node
## Tur 180: bölüm adları, hikâye kartı başlığı, mağaza ve silah duyurusu `to_upper()` ile
## "Sessiz" → "SESSIZ", "Arşivi" → "ARŞIVI" yapıyordu (Godot dil-bağımsız büyütür). Hepsi artık
## `PixelText.upper` kullanıyor; bu test her bölüm adında i → İ, ı → I eşleşmesini korur.


func _ready() -> void:
	var ok := true
	for n in GameState.LEVEL_NAMES:
		var src := String(n)
		var up := PixelText.upper(src)
		if up.length() != src.length():
			ok = false
			print("UZUNLUK: %s -> %s" % [src, up])
			continue
		for i in src.length():
			var c := src[i]
			if (c == "i" and up[i] != "İ") or (c == "ı" and up[i] != "I"):
				ok = false
				print("HATALI: %s -> %s" % [src, up])
				break
	if PixelText.upper("Sessiz Koridor") != "SESSİZ KORİDOR":
		ok = false
		print("HATALI: Sessiz Koridor -> %s" % PixelText.upper("Sessiz Koridor"))
	print("TURKCE BUYUK HARF: %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit(0 if ok else 1)
