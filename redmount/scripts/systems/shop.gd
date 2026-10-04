## Shop — mağaza ürün tanımları (Görev 14).
##
## Kalıcı yükseltmeler. `Save.total_coins` ile satın alınır (`Save.buy`), `Save.owns`
## ile sorgulanır, Main tarafından her koşuda uygulanır. Ana plan md. 20.
class_name Shop
extends RefCounted

const ITEMS: Array[Dictionary] = [
	{"id": "low_kick", "name": "Alçak tekme", "desc": "Çömel + saldırı: yakın düşmanı geriye iter.", "cost": 35, "unlock_level": 1},
	{"id": "combo_finish", "name": "Üçüncü vuruş", "desc": "Yumruk kombosuna güçlü son vuruş ekler.", "cost": 55, "unlock_level": 2},
	{"id": "uppercut", "name": "Aparkat", "desc": "Zıplama + saldırı: düşmanı yukarı savurur.", "cost": 70, "unlock_level": 3},
	{"id": "dash_strike", "name": "Dash vuruşu", "desc": "Dash sırasında saldırı: ileri atılan yumruk.", "cost": 85, "unlock_level": 4},
	{"id": "ground_slam", "name": "Yere çakma", "desc": "Havada çömel + saldırı: zırhı sarsan iniş.", "cost": 100, "unlock_level": 5},
	{
		"id": "double_coin",
		"name": "Çift coin",
		"desc": "Topladığın coin 2 kat sayılır.",
		"cost": 60,
	},
]

## Her satın alma bir sonraki kademeyi açar. Dizi indeksi mevcut kademedir.
const UPGRADES: Array[Dictionary] = [
	{"id": "fist_power", "name": "Yumruk gücü", "desc": "Silahsız hasar +%12", "costs": [45, 75, 110]},
	{"id": "combo_speed", "name": "Kombo hızı", "desc": "Hazırlık ve toparlanma +%6 hızlı", "costs": [40, 70, 105]},
	{"id": "finisher_power", "name": "Bitirici gücü", "desc": "Üçüncü vuruş hasarı +%25", "costs": [60, 95, 140], "requires": "combo_finish"},
	{"id": "weapon_capacity", "name": "Silah kapasitesi", "desc": "Dayanıklılık ve yedek cephane +%20", "costs": [50, 85, 125]},
	{"id": "weapon_power", "name": "Yakın silah ustalığı", "desc": "Sopa ve bıçak hasarı +%15", "costs": [55, 90, 130]},
	{"id": "firearm_power", "name": "Atış eğitimi", "desc": "Ateşli silah hasarı +%15", "costs": [60, 95, 140]},
	{"id": "max_health", "name": "Dayanıklılık", "desc": "Azami can +15", "costs": [55, 90, 135]},
]


static func item(id: String) -> Dictionary:
	for it in ITEMS:
		if it.id == id:
			return it
	return {}


static func upgrade(id: String) -> Dictionary:
	for it in UPGRADES:
		if it.id == id:
			return it
	return {}
