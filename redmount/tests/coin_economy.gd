## Coin ekonomisi eğrisi (tur 145): 36 bölümde toplanabilir azami coin ölçülür, mağaza
## kataloğunun (hareket + kademeler + kostüm) kampanyanın neresinde tükendiği simüle edilir.
## Hedef: ilk bölümden sonra bir hareket alınabilsin, ama katalog ortada bitip coin'in
## ikinci yarıda karşılıksız kalmasın.
##
##  godot --headless --path . res://tests/coin_economy.tscn
extends Node

const GAME_STATE_SCRIPT := preload("res://scripts/systems/game_state.gd")
## Gevşek coin ve kırılan kaptan saçılan coin 2 değerinde (`coin_pickup.gd`); film rulosu +10.
const COIN_VALUE := 2
const SECRET_VALUE := 10

var _failed := false


func _ready() -> void:
	var per_level: Array[int] = []
	for i in GAME_STATE_SCRIPT.LEVELS.size():
		var level: Node = (load(GAME_STATE_SCRIPT.LEVELS[i]) as PackedScene).instantiate()
		add_child(level)
		for _f in 3:
			await get_tree().process_frame
		var total := 0
		for n in _all(level):
			if n.is_in_group(&"coin"):
				total += COIN_VALUE
			elif n is BreakableProp:
				var c: int = n.coins_override if n.coins_override >= 0 \
						else int(BreakableProp.KINDS.get(n.kind, {}).get("coins", 0))
				total += c * COIN_VALUE
			if n.is_in_group(&"secret_zone"):
				total += SECRET_VALUE
		per_level.append(total)
		print("ECON Bölüm %2d: azami %d coin" % [i + 1, total])
		level.queue_free()
		await get_tree().process_frame

	var catalogue := _catalogue_total()
	print("ECON katalog toplamı: %d" % catalogue)
	_check(int(per_level[0] * 0.5) >= _cheapest_move(), "yarı toplayan oyuncu Bölüm 1 sonunda bir hareket alabilmeli")
	var half := _completion_level(per_level, 0.5)
	var full := _completion_level(per_level, 1.0)
	print("ECON katalog tükenişi: %%50 toplayan Bölüm %d, %%100 toplayan Bölüm %d" % [half, full])
	_check(half >= 16, "yarı toplayan oyuncu kataloğu kampanyanın ilk yarısında bitirmemeli (Bölüm %d)" % half)
	_check(half != -1, "yarı toplayan oyuncu kataloğu kampanya içinde bitirebilmeli")
	_check(full >= 10, "her şeyi toplayan oyuncu kataloğu ilk 10 bölümde bitirmemeli (Bölüm %d)" % full)
	if _failed:
		get_tree().quit(1)
		return
	print("COIN ECONOMY: PASS")
	get_tree().quit(0)


## Oyuncu her bölümde `rate` oranında toplar; Çift coin kilidi açılıp parası yetince
## önce onu alır (en akılcı yol, en hızlı tükeniş). Katalog bitince bölüm no, bitmezse -1.
## Başarım/ustalık/günlük ödülleri sayılmaz: bunlar kampanya akışının dışında gelir.
func _completion_level(per_level: Array[int], rate: float) -> int:
	var dbl := _item("double_coin")
	var dbl_unlock := int(dbl.get("unlock_level", 0))
	var remaining := _catalogue_total()
	var bank := 0
	var mult := 1
	for i in per_level.size():
		if mult == 1 and i >= dbl_unlock and bank >= int(dbl.cost):
			bank -= int(dbl.cost)
			remaining -= int(dbl.cost)
			mult = 2
		bank += int(per_level[i] * rate) * mult
		if bank >= remaining:
			return i + 1
	return -1


func _catalogue_total() -> int:
	var sum := 0
	for it in Shop.ITEMS:
		sum += int(it.cost)
	for it in Shop.UPGRADES:
		for c in it.costs:
			sum += int(c)
	for it in Shop.COSTUMES:
		sum += int(it.cost)
	return sum


func _cheapest_move() -> int:
	var best := 1 << 30
	for it in Shop.ITEMS:
		if it.id != "double_coin":
			best = mini(best, int(it.cost))
	return best


func _item(id: String) -> Dictionary:
	for it in Shop.ITEMS:
		if it.id == id:
			return it
	return {}


func _all(n: Node) -> Array:
	var out := [n]
	for c in n.get_children():
		out.append_array(_all(c))
	return out


func _check(ok: bool, msg: String) -> void:
	if not ok:
		_failed = true
		push_error("COIN ECONOMY FAIL: " + msg)
