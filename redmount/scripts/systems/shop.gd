## Shop — mağaza ürün tanımları (Görev 14).
##
## Kalıcı yükseltmeler. `Save.total_coins` ile satın alınır (`Save.buy`), `Save.owns`
## ile sorgulanır, Main tarafından her koşuda uygulanır. Ana plan md. 20.
class_name Shop
extends RefCounted

const ITEMS: Array[Dictionary] = [
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


## Kostümler: aynı sprite, giysi palet takası (`shaders/player_costume.gdshader`)
## + tek küçük bonus. Coin'in yükseltmeler bittikten sonraki uzun vadeli hedefi.
## Adlar Türkçe büyük harfle yazılır (`to_upper` i/ı ayrımını bilmez).
## `shade`/`light`: ceketin koyu → açık rampası; `pants_shade`/`pants_light`: pantolonun
## (yoksa ceketinki). Pantolon pikselleri sayfada işaretli (`tools/gen_costume_mask.py`).
## İki rampanın koyu ucu yakın tutulur: maskenin kaçırdığı gölgeli bacak pikseli
## ceket rengine düşse de gölge gibi okunur. "sokak" varsayılan, bedava.
## bonus anahtarları: max_health (can +), fist (yumruk hasarı ×), weapon_capacity
## (silah dayanıklılığı/cephane ×), heal (yiyecek iyileştirmesi ×).
## `accessory`: başlık görüntüsü (`assets/anim/costume_acc/<ad>.png`, `CostumeAccessory`);
## `attach`: "crown" (saç tepesi, varsayılan) | "brow" (alın, bandana).
const DEFAULT_COSTUME := "sokak"
const COSTUMES: Array[Dictionary] = [
	{"id": "sokak", "name": "SOKAK ÇEKETİ", "desc": "Siyah deri. Redmount'un kendisi.", "cost": 0},
	{
		"id": "vapurcu", "name": "VAPURCU", "desc": "Lacivert iş ceketi. Azami can +10",
		"cost": 120, "unlock_level": 3,
		"shade": Color8(10, 18, 48), "light": Color8(70, 110, 180),
		"pants_shade": Color8(12, 14, 24), "pants_light": Color8(118, 122, 132), "bonus": {"max_health": 10},
		"accessory": "vapurcu",
	},
	{
		"id": "hamal", "name": "HAMAL", "desc": "Haki iş tulumu. Silah dayanıklılığı +%15",
		"cost": 150, "unlock_level": 8,
		"shade": Color8(26, 28, 12), "light": Color8(120, 120, 70),
		"pants_shade": Color8(22, 22, 12), "pants_light": Color8(92, 90, 56), "bonus": {"weapon_capacity": 0.15},
		"accessory": "hamal",
	},
	{
		"id": "kahveci", "name": "KAHVECİ", "desc": "Kahve tonu yelek. Yiyecek iyileştirmesi +%25",
		"cost": 180, "unlock_level": 14,
		"shade": Color8(40, 24, 12), "light": Color8(190, 140, 85),
		"pants_shade": Color8(18, 12, 10), "pants_light": Color8(96, 76, 62), "bonus": {"heal": 0.25},
		"accessory": "kahveci",
	},
	{
		"id": "kizil", "name": "KIZIL DAĞ", "desc": "Adının rengi. Yumruk hasarı +%8",
		"cost": 240, "unlock_level": 20,
		"shade": Color8(40, 6, 10), "light": Color8(190, 50, 45),
		"pants_shade": Color8(14, 10, 14), "pants_light": Color8(84, 74, 82), "bonus": {"fist": 0.08},
		"accessory": "kizil", "attach": "brow",
	},
]


static func costume(id: String) -> Dictionary:
	for it in COSTUMES:
		if it.id == id:
			return it
	return COSTUMES[0]


## Giyili kostümün verilen bonusu (yoksa 0).
static func costume_bonus(key: String) -> float:
	var bonus: Dictionary = costume(Save.costume).get("bonus", {})
	return float(bonus.get(key, 0.0))


## Kostümün palet malzemesi; varsayılan kostümde null (rig malzemesiz kalır).
static func costume_material(id: String) -> ShaderMaterial:
	var it := costume(id)
	if not it.has("shade"):
		return null
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://shaders/player_costume.gdshader")
	mat.set_shader_parameter(&"shade", it.shade)
	mat.set_shader_parameter(&"light", it.light)
	mat.set_shader_parameter(&"pants_shade", it.get("pants_shade", it.shade))
	mat.set_shader_parameter(&"pants_light", it.get("pants_light", it.light))
	mat.set_meta(&"costume", it.id)
	return mat


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
