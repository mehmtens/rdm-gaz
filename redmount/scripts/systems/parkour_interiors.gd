## ParkourInteriors — bölüm başına iç mekân (gökyüzü görünmeyen) x aralıkları.
##
## Üretici: tools/gen_parkour_interiors.py. Bölümler 1500 px aralıkla görüntülenip
## etiketlendi; kampanya bölümleri elle doğrulanmış aralıklardır
## (bkz. docs/DAN-THE-MAN-PARKUR.md). Bu dosyayı elle düzenlemeyin.
## Anahtar: GameState.LEVELS indeksi. Değer: Vector2(sol_x, sağ_x) aralıkları.
## Bölüm arka planları değişirse tablo yeniden üretilmelidir.
class_name ParkourInteriors
extends RefCounted

const RANGES := {
	5: [Vector2(-1000, 1000000)],
	6: [Vector2(-1000, 1000000)],
	7: [Vector2(-1000, 1000000)],
	10: [Vector2(-1000, 1000000)],
	11: [Vector2(-1000, 1000000)],
	12: [Vector2(-1000, 0), Vector2(42750, 57750), Vector2(71250, 83250), Vector2(92250, 101250), Vector2(113000, 1000000)],
	13: [Vector2(-1000, 0), Vector2(28500, 58500), Vector2(75000, 90000), Vector2(113000, 1000000)],
	14: [Vector2(-1000, 0), Vector2(43500, 101250), Vector2(117000, 1000000)],
	15: [Vector2(-1000, 0), Vector2(44250, 104250), Vector2(121000, 1000000)],
	16: [Vector2(-1000, 0), Vector2(44250, 89250), Vector2(117000, 1000000)],
	17: [Vector2(-1000, 0), Vector2(14250, 57750), Vector2(72750, 102750), Vector2(117000, 1000000)],
	18: [Vector2(-1000, 0), Vector2(44250, 1000000)],
	19: [Vector2(-1000, 0), Vector2(44250, 1000000)],
	20: [Vector2(-1000, 0), Vector2(29250, 44250), Vector2(72750, 102750), Vector2(117000, 1000000)],
	21: [Vector2(-1000, 0), Vector2(29250, 89250), Vector2(117000, 1000000)],
	22: [Vector2(-1000, 0), Vector2(29250, 89250), Vector2(117000, 1000000)],
	23: [Vector2(-1000, 0), Vector2(32250, 248250), Vector2(290000, 1000000)],
	24: [Vector2(-1000, 0), Vector2(56250, 68250), Vector2(83250, 1000000)],
	25: [Vector2(-1000, 0), Vector2(29250, 83250), Vector2(98250, 1000000)],
	26: [Vector2(-1000, 0), Vector2(56250, 98250), Vector2(112000, 1000000)],
	27: [Vector2(-1000, 0), Vector2(57000, 83250), Vector2(112000, 1000000)],
	28: [Vector2(-1000, 0), Vector2(68250, 98250), Vector2(112000, 1000000)],
	29: [Vector2(-1000, 0), Vector2(56250, 1000000)],
	30: [Vector2(-1000, 0), Vector2(41250, 1000000)],
	31: [Vector2(-1000, 0), Vector2(56250, 1000000)],
	32: [Vector2(-1000, 0), Vector2(41250, 1000000)],
	33: [Vector2(-1000, 0), Vector2(59250, 83250), Vector2(112000, 1000000)],
	34: [Vector2(-1000, 0), Vector2(41250, 83250), Vector2(112000, 1000000)],
	35: [Vector2(-1000, 201000), Vector2(237000, 246000), Vector2(273000, 1000000)],
}


static func is_interior(level_index: int, x0: float, x1: float) -> bool:
	for r in RANGES.get(level_index, []):
		if r.x < x1 and r.y > x0:
			return true
	return false
