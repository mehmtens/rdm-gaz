## ParkourSet — elle ölçülmüş İstanbul parkur parçaları (Dan the Man tarzı yoğun ritim).
##
## Her parça ana yolun üstüne kurulur ve oyuncudan tek, okunur bir hareket fikri
## ister; hiçbiri ölümcül boşluk içermez (düşen oyuncu sokağa iner, yeniden dener).
## Görünüm yalnız mahalle setindeki piksel sanattan çizilir — düz renk kutu yok.
##
##  tente_duvar : tezgâh tentesine bas, sıçra, kiremitli bahçe duvarını aş.
##  balkon      : cumba balkonlarını basamak gibi kullanıp evin çatısına çık.
##  cati        : tenteden çatıya; ara sokak boşluklarını atlayarak çatı zinciri.
##  baca        : iki baca duvarı arasında (isteğe bağlı) duvar zıplaması, tepede ödül.
##  sekme       : art arda üç tente; her biri bir öncekinden yüksek, sonda kemer üstü ödül.
## İç mekân (han deposu, hamam, sarnıç, matbaa, pompa salonu) setleri:
##  kasa        : sandık basamakları; tepede ödül, öbür yandan iniş.
##  iskele      : ahşap iskele katlarıyla yüksek sandık barikatını aşma.
##  direk       : iki taş direk arasında (isteğe bağlı) duvar zıplaması.
##
## Koordinatlar: parçanın kökü sol kenar ve sokak zemini (y = 0) üstündedir.
## Redmount ölçüleri: zıplama ~120 px, koşarak sıçrama ~265 px, tente ~240/345 px.
class_name ParkourSet
extends Node2D

const COIN := preload("res://scenes/pickups/Coin.tscn")
const HEALTH := preload("res://scenes/pickups/HealthPickup.tscn")
const AMMO := preload("res://scenes/pickups/AmmoPickup.tscn")
const ARMOR := preload("res://scenes/pickups/ArmorPickup.tscn")

const WALL := preload("res://assets/environment/mahalle/wall_plain.png")
const ROOF_CAP := preload("res://assets/environment/kit/roof_b.png")
const ROOF_SLAB := preload("res://assets/environment/mahalle/roof_a.png")
const PILLAR := preload("res://assets/environment/kit/wall_pillar.png")
const BALCONY := preload("res://assets/environment/mahalle/window_balcony.png")
const CRATE := preload("res://assets/environment/mahalle/crate_wood_v2.png")
const SCAFFOLD := preload("res://assets/environment/mahalle/scaffold_deck_v2.png")
const POST := preload("res://assets/environment/kit/scaffold_post.png")
const HOUSES := [
	preload("res://assets/environment/mahalle/house_a.png"),
	preload("res://assets/environment/mahalle/house_b.png"),
	preload("res://assets/environment/mahalle/house_c.png"),
]
## Ev sanatlarında kiremit çatının bittiği satır oranı (gövde üst kenarı).
const HOUSE_EAVE := [0.2, 0.17, 0.0]

const WIDTHS := {
	"tente_duvar": 760.0,
	"balkon": 700.0,
	"cati": 1720.0,
	"baca": 520.0,
	"sekme": 1320.0,
	"kasa": 900.0,
	"iskele": 820.0,
	"direk": 520.0,
	"engel": 520.0,
}
const INTERIOR_KINDS := ["kasa", "iskele", "direk"]

@export_enum("tente_duvar", "balkon", "cati", "baca", "sekme", "kasa", "iskele", "direk", "engel") var kind: String = "tente_duvar"
## Yer seçimi için tohum: aynı türün ev sanatı / ödülü bölümden bölüme değişir.
@export var variant: int = 0
## Setin tepesindeki ödül (boşsa türün varsayılanı ya da hiç).
@export var reward: PackedScene


## Nöbetçi yerleri (yerel koordinat): rol "tepe" = setin üstünde bekleyen,
## "nisan" = yüksekten ateş eden (tüfekli için), "zemin" = setin dibinde/arkasında.
## late: Kitap 3. Oradaki sandık nöbetçisi uzaktan ateş eden seçkin muhafızdır; 180 px'lik
## tepede geri çekilemez, basamaktan çıkan oyuncuyu siperiz vurur. Bu yüzden iniş
## tarafındaki düz zeminde bekler: oyuncu yığının tepesinden üstüne iner.
static func guard_spots(k: String, late := false) -> Array:
	if k == "kasa" and late:
		return [{"pos": Vector2(820, 0), "role": "zemin"}]
	match k:
		"tente_duvar": return [{"pos": Vector2(400, -250), "role": "nisan"}, {"pos": Vector2(680, 0), "role": "zemin"}]
		"balkon": return [{"pos": Vector2(430, -330), "role": "tepe"}]
		"cati": return [{"pos": Vector2(925, -270), "role": "tepe"}, {"pos": Vector2(1400, -230), "role": "tepe"}]
		"sekme": return [{"pos": Vector2(430, 0), "role": "zemin"}, {"pos": Vector2(985, 0), "role": "zemin"}]
		"kasa": return [{"pos": Vector2(435, -180), "role": "tepe"}]
		"iskele": return [{"pos": Vector2(505, -230), "role": "nisan"}]
		"engel": return [{"pos": Vector2(420, 0), "role": "zemin"}]
	return []


static func width_of(k: String) -> float:
	return WIDTHS.get(k, 800.0)


func _ready() -> void:
	match kind:
		"balkon": _build_balcony_climb()
		"cati": _build_rooftops()
		"baca": _build_chimney()
		"sekme": _build_bounce_chain()
		"kasa": _build_crate_steps()
		"iskele": _build_scaffold_climb()
		"direk": _build_chimney(false)
		"engel": _build_cover()
		_: _build_awning_wall()


# --- Parçalar ---------------------------------------------------------------

func _build_awning_wall() -> void:
	# Tezgâh duvarın dibine dayalı: duvarın önüne düşen herkes yeniden tenteye iner,
	# arada geri dönmek zorunda kalınan ölü cep yok.
	_awning(220, 240, 64)
	_wall_block(340, 120, 250)
	# Coin yayı sıçrama eğrisini çizer: oyuncu nereye düşeceğini görür.
	for i in 7:
		var t := float(i) / 6.0
		_coin(160 + t * 420.0, -120.0 - sin(t * PI) * 220.0)
	_coin(620, -55)
	_coin(680, -55)
	if reward != null:
		_pickup(reward, 400, -300)


func _build_balcony_climb() -> void:
	var house := posmod(variant, 2)  # cumbalı iki ev (düz damlı ev çatı rotasına kalır)
	var top := -330.0
	_house_block(250, 300, top, house)
	# Ön yüze asılı üç balkon: tek yön, alttan geçilir; her biri 110 px yukarıda.
	for k in 3:
		_balcony_ledge(170, -110.0 - k * 110.0, 160)
	_coin(170, -170)
	_coin(170, -280)
	for k in 4:
		_coin(300 + k * 60.0, top - 50.0)
	if reward != null:
		_pickup(reward, 480, top - 45.0)


func _build_rooftops() -> void:
	# Tezgâh ilk evin duvarına dayalı (arada ölü cep yok).
	_awning(180, 180, 64)
	var tops := [-230.0, -270.0, -230.0]
	var x := 270.0
	for i in tops.size():
		var w := 330.0
		_house_block(x, w, tops[i], 2 if i == 1 else (variant + i) % 2)
		for k in 4:
			_coin(x + 50.0 + k * 75.0, float(tops[i]) - 55.0)
		x += w
		if i < tops.size() - 1:
			# Ara sokak: düşen oyuncu iki balkonla (ileriye doğru) yeniden çatıya çıkar.
			_balcony_ledge(x + 45.0, -110.0, 90)
			_balcony_ledge(x + 115.0, float(tops[i + 1]) + 85.0, 90)
			x += 160.0
	if reward != null:
		_pickup(reward, 270.0 + 330.0 + 160.0 + 165.0, -270.0 - 50.0)


func _build_chimney(outdoor := true) -> void:
	# Baca duvarları zeminden 135 px yukarıda başlar: sokak altından serbestçe geçilir.
	_pillar(150, 70, -135.0, 300.0, outdoor)
	_pillar(380, 70, -135.0, 300.0, outdoor)
	# Duvarlar arası 160 px — duvar kayması + zıplamasıyla tırmanılır.
	for k in 4:
		_coin(265, -190.0 - k * 60.0)
	if outdoor:
		_roof_ledge(265, -450.0, 300)
	else:
		_scaffold_ledge(265, -450.0, 300)
	_pickup(reward if reward != null else [HEALTH, ARMOR, AMMO][posmod(variant, 3)], 265, -495)
	_coin(205, -490)
	_coin(325, -490)


func _build_bounce_chain() -> void:
	# Tezgâh + duvar çiftleri: her tente duvarın dibine dayanır, böylece nereye
	# inilirse inilsin duvarın önü sekme yüzeyidir (duvar yüzüne çarpan da yeniden sekip aşar).
	_awning(100, 200, 60)
	_wall_block(200, 90, 170)
	_awning(680, 240, 60)
	_wall_block(800, 90, 220)
	_awning(1180, 200, 60)
	# Son tentede zıplama tuşunu basılı tutan, kemer üstündeki ödüle yetişir.
	_roof_ledge(1180, -360.0, 170)
	for i in 4:
		_coin(130 + i * 115.0, -250.0 - sin(float(i) / 3.0 * PI) * 70.0)
		_coin(700 + i * 115.0, -290.0 - sin(float(i) / 3.0 * PI) * 70.0)
	_coin(1150, -410)
	_coin(1210, -410)
	if reward != null:
		_pickup(reward, 1180, -405)


func _build_crate_steps() -> void:
	# Depo sandıkları: 60 px basamaklarla 180 px'e çıkan, öbür yandan inen yığın.
	var c := 90.0
	var heights := [60.0, 120.0, 180.0, 180.0, 120.0, 60.0]
	for i in heights.size():
		_crate_stack(120.0 + i * c, c, heights[i])
	for i in heights.size():
		_coin(120.0 + i * c + c * 0.5, -float(heights[i]) - 55.0)
	# Tepe ödülü: yığının üstünde asılı ahşap raf (isteğe bağlı küçük zıplama, 110 px).
	_scaffold_ledge(435, -290.0, 200)
	_pickup(reward if reward != null else [AMMO, HEALTH, ARMOR][posmod(variant, 3)], 435, -335)


func _build_scaffold_climb() -> void:
	# Yüksek sandık barikatı (230 px); yüzüne çatılmış iki iskele katı basamak olur.
	_crate_stack(150, 90, 60)
	_scaffold_ledge(345, -110.0, 150)
	_scaffold_ledge(345, -215.0, 150)
	_crate_stack(430, 150, 230)
	_crate_stack(580, 90, 110)
	_coin(195, -115)
	_coin(345, -165)
	_coin(345, -270)
	for k in 3:
		_coin(445 + k * 45.0, -285)
	_coin(625, -165)
	if reward != null:
		_pickup(reward, 470, -280)


func _build_cover() -> void:
	# Siper: iki katlı sandık yığını; arkasında bekleyen nöbetçi. Üstünden atlanır
	# ya da sandığın önünde dövüşülür.
	_crate_stack(150, 90, 90)
	_crate_stack(240, 90, 60)
	for i in 5:
		var t := float(i) / 4.0
		_coin(130 + t * 260.0, -150.0 - sin(t * PI) * 70.0)
	if reward != null:
		_pickup(reward, 195, -140)


# --- Yapı taşları ------------------------------------------------------------

func _awning(cx: float, w: float, h: float) -> void:
	var a := AwningBounce.new()
	a.width = w
	a.height = h
	a.position = Vector2(cx, 0)
	add_child(a)


## Kiremit kapaklı bahçe / han duvarı: zeminden yükselen katı engel.
func _wall_block(left: float, w: float, h: float) -> void:
	var body := _solid(Rect2(left, -h, w, h))
	body.add_child(_Art.new(_Art.A_WALL, Vector2(w, h), 0))


## Ev bloğu: gövde katıdır, üstü yürünür çatı/dam.
func _house_block(left: float, w: float, top: float, house: int) -> void:
	var h := -top
	var body := _solid(Rect2(left, top, w, h))
	body.add_child(_Art.new(_Art.A_HOUSE, Vector2(w, h), house))


## Baca / kule duvarı: yerden kopuk asılı katı sütun (iç mekânda kiremit başlıksız).
func _pillar(cx: float, w: float, bottom: float, h: float, outdoor := true) -> void:
	var body := _solid(Rect2(cx - w * 0.5, bottom - h, w, h))
	body.add_child(_Art.new(_Art.A_PILLAR, Vector2(w, h), 0 if outdoor else 1))


## Sandık yığını: zeminden yükselen katı basamak.
func _crate_stack(left: float, w: float, h: float) -> void:
	var body := _solid(Rect2(left, -h, w, h))
	body.add_child(_Art.new(_Art.A_CRATES, Vector2(w, h), 0))


func _solid(r: Rect2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = r.position + r.size * 0.5
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = r.size
	col.shape = shape
	body.add_child(col)
	body.add_to_group(&"parkour_solid")
	add_child(body)
	return body


func _balcony_ledge(cx: float, y: float, w: float) -> void:
	_oneway(cx, y, w, _Art.A_BALCONY)


func _roof_ledge(cx: float, y: float, w: float) -> void:
	_oneway(cx, y, w, _Art.A_ROOF)


func _scaffold_ledge(cx: float, y: float, w: float) -> void:
	_oneway(cx, y, w, _Art.A_SCAFFOLD)


func _oneway(cx: float, y: float, w: float, art: int) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 128
	body.collision_mask = 0
	body.position = Vector2(cx, y)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(w, 12.0)
	col.shape = shape
	col.position = Vector2(0, 6.0)
	col.one_way_collision = true
	body.add_child(col)
	body.add_child(_Art.new(art, Vector2(w, 0), 0))
	add_child(body)


func _coin(x: float, y: float) -> void:
	_pickup(COIN, x, y)


func _pickup(scene: PackedScene, x: float, y: float) -> void:
	var node := scene.instantiate()
	node.position = Vector2(x, y)
	add_child(node)


## Parça sanatı: gövdenin merkezine göre çizilir (StaticBody2D konumu merkezdir).
const _OWP := preload("res://scripts/systems/one_way_platform.gd")


class _Art extends Node2D:
	enum { A_WALL, A_HOUSE, A_PILLAR, A_BALCONY, A_ROOF, A_CRATES, A_SCAFFOLD }
	var _kind: int
	var _size: Vector2
	var _house: int

	func _init(kind: int, size: Vector2, house: int) -> void:
		_kind = kind
		_size = size
		_house = house
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		z_index = -1

	func _draw() -> void:
		var hw := _size.x * 0.5
		var hh := _size.y * 0.5
		match _kind:
			A_WALL:
				_tile_down(WALL, Rect2(-hw, -hh, _size.x, _size.y), Color("cfc3c0"))
				var cap_h := 34.0
				draw_texture_rect(ROOF_CAP, Rect2(-hw - 12.0, -hh - cap_h + 10.0, _size.x + 24.0, cap_h), false)
			A_PILLAR:
				_tile_down(PILLAR, Rect2(-hw, -hh, _size.x, _size.y), Color.WHITE)
				if _house == 0:
					draw_texture_rect(ROOF_CAP, Rect2(-hw - 10.0, -hh - 24.0, _size.x + 20.0, 32.0), false)
			A_CRATES:
				# Kare sandıklar alttan üste dizilir; üst sıra yüksekliğe göre kırpılır.
				var side := minf(_size.x, 90.0)
				var y := hh
				var row := 0
				while y > -hh + 0.5:
					var h := minf(side, y + hh)
					var x := -hw
					while x < hw - 0.5:
						var w := minf(side, hw - x)
						var tint := Color("d8c8b4") if (row + int((x + hw) / side)) % 2 == 0 else Color("c4b29c")
						draw_texture_rect_region(CRATE, Rect2(x, y - h, w, h),
							Rect2(227, 974 - 781 * h / side, 893 * w / side, 781 * h / side), tint)
						x += side
					y -= side
					row += 1
			A_SCAFFOLD:
				# Ahşap iskele tablası + aşağı inen iki dikme.
				var legs := 60.0
				for lx in [-hw + 10.0, hw - 14.0]:
					draw_texture_rect(POST, Rect2(lx - 6.0, 4.0, 14.0, legs), false)
				draw_texture_rect_region(SCAFFOLD, Rect2(-hw - 6.0, -8.0, _size.x + 12.0, 40.0),
					Rect2(27, 149, 1929, 260))
				_OWP.draw_dark_edge(self, -hw - 4.0, hw + 4.0, 0.0)
			A_HOUSE:
				var tex: Texture2D = HOUSES[_house]
				var eave: float = HOUSE_EAVE[_house]
				# Gövde katı kutuya oturur, kiremit çatı kutunun üstüne taşar.
				var body_h := _size.y
				var full_h := body_h / (1.0 - eave) if eave > 0.0 else body_h
				var roof_h := full_h - body_h
				draw_texture_rect(tex, Rect2(-hw - 8.0, -hh - roof_h, _size.x + 16.0, full_h), false)
				if eave <= 0.0:
					draw_texture_rect(ROOF_SLAB, Rect2(-hw - 10.0, -hh - 22.0, _size.x + 20.0, 34.0), false)
			A_BALCONY:
				# Yalnız korkuluk + taş döşeme kesiti; döşeme üstü platform yüzeyidir.
				var bw := _size.x + 30.0
				var bh := bw * 72.0 / 204.0
				draw_texture_rect_region(BALCONY, Rect2(-bw * 0.5, -bh * 47.0 / 72.0, bw, bh),
					Rect2(0, 60, 204, 72))
			A_ROOF:
				draw_texture_rect(ROOF_SLAB, Rect2(-hw - 8.0, -14.0, _size.x + 16.0, 34.0), false)

	## Dokuyu genişliğe ölçekleyip dikeyde tekrar eder (taş sırası bozulmaz).
	func _tile_down(tex: Texture2D, r: Rect2, tint: Color) -> void:
		var tile_h := r.size.x * tex.get_height() / tex.get_width()
		var y := r.position.y
		while y < r.end.y - 0.5:
			var h := minf(tile_h, r.end.y - y)
			draw_texture_rect_region(tex, Rect2(r.position.x, y, r.size.x, h),
				Rect2(0, 0, tex.get_width(), tex.get_height() * h / tile_h), tint)
			y += h
