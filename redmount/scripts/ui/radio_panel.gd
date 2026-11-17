## RadioPanel — oynanışı DURDURMAYAN telsiz konuşması (Dan the Man'in oyun içi sohbeti).
##
## Ekranın üstünde piksel çerçeveli panel: solda konuşanın piksel portresi, sağda
## ad + harf harf yazılan metin. Kuyruklu: art arda gelen satırlar sırayla çıkar.
## Bölüm (DtmLevel._radio) oyuncu belirli x'i geçince `say()` çağırır.
class_name RadioPanel
extends CanvasLayer

const PORTRAITS := {
	"gazelle": preload("res://assets/ui/pixel/portre_gazelle.png"),
	"redmount": preload("res://assets/ui/pixel/portre_redmount.png"),
	"karahanli": preload("res://assets/ui/pixel/portre_karahanli.png"),
	"telsiz": preload("res://assets/ui/pixel/portre_telsiz.png"),
}
const NAME_COLOR := {
	"gazelle": Color(0.55, 0.9, 0.82), "redmount": Color(1.0, 0.62, 0.45),
	"karahanli": Color(1.0, 0.45, 0.4), "telsiz": Color(1.0, 0.82, 0.45),
}
const CHARS_PER_SEC := 38.0
const HOLD := 2.4
## Panel tam açıkken üst bandın aşağı kayma payı: panel altı (116) + 6 boşluk − DALGA rozeti (12).
const BAND := 110.0
## Dost konuşmacılar (hikâye satırları): kilitli arenada dövüş sürerken kuyrukta bekler,
## arena temizlenince CALM saniye sonra çıkar ("TEMİZ!" önce okunsun). Düşman telsizi /
## tehdidi dövüşün parçasıdır, beklemez. Tur 248 ölçümü: 108 satırın 27'si dost satırı
## olarak arena içinde tetikleniyordu; oyuncu dövüşürken okuyamıyordu.
const HOLD_IN_ARENA := ["gazelle", "redmount"]
const CALM := 0.8
## Arena kapısı kapanırken AÇIK olan dost satırı: okuma süresinin (yazılış + bekleme) en çok
## bu kadarı geçtiyse panelden çekilir, kuyruğun başına döner ve dövüş bitince baştan okunur.
## Tur 255 denetimi: Bölüm 30/31/32/34'te bir sonraki hedefi söyleyen satır arenadan
## 160–540 px önce tetikleniyor, okunmadan dövüşe karışıyordu. Okumanın çoğu bittiyse
## satır yerinde kalır (yarım cümleyi tekrar etmek ritmi bozar).
const REQUEUE_BEFORE := 0.6

static var _instance: RadioPanel

var _queue: Array = []
var _panel: PanelContainer
var _portrait: TextureRect
var _name: Label
var _text: Label
var _full := ""
var _shown := 0.0
var _hold := 0.0
var _slide := 0.0
var _active := false
var _calm := 0.0
var _cur: Array = []
var _age := 0.0
var _life := 1.0


## `urgent`: senaryolu, dövüşün içindeki anı anlatan satır (ör. Bölüm 20 "Kemal kaçıyor!");
## arena beklemesine takılmaz.
static func say(tree: SceneTree, who: String, speaker: String, text: String, urgent := false) -> void:
	if _instance == null or not is_instance_valid(_instance):
		_instance = RadioPanel.new()
		tree.current_scene.add_child(_instance)
	_instance._queue.append([who, speaker, text, urgent])


## Sıradaki satır arena dövüşü yüzünden bekletilmeli mi?
func _held(it: Array) -> bool:
	if it.size() > 3 and it[3]:
		return false
	if not HOLD_IN_ARENA.has(it[0]):
		return false
	return _calm > 0.0


## Bu satır dost hikâye satırı mı (acil değil)? Dövüşte beklemeye tabi olanlar.
func _held_now(it: Array) -> bool:
	if it.is_empty() or (it.size() > 3 and it[3]):
		return false
	return HOLD_IN_ARENA.has(it[0])


## Telsiz şu an üst bantta ne kadar yer kaplıyor: HUD'un üst öğeleri (dalga rozeti, kombo,
## yer afişi, boss çubuğu) bu kadar aşağı kayar, panelin altında kalmaz.
static func top_inset() -> float:
	if _instance == null or not is_instance_valid(_instance) or _instance._panel == null:
		return 0.0
	return BAND * _instance._panel.modulate.a


func _ready() -> void:
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel = PanelContainer.new()
	_panel.add_theme_stylebox_override(&"panel", PixelUI.box("panel_hud", 14))
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	# Üstte, HUD'un sağında: oyuncuyu ve zemini kapatmaz.
	_panel.anchor_top = 0.0
	_panel.anchor_bottom = 0.0
	_panel.offset_left = -230
	_panel.offset_right = 590
	_panel.offset_top = 16
	_panel.offset_bottom = 116
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 14)
	_panel.add_child(row)
	_portrait = TextureRect.new()
	_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_portrait.custom_minimum_size = Vector2(72, 72)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(_portrait)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override(&"separation", 2)
	row.add_child(col)
	_name = Label.new()
	col.add_child(_name)
	_text = Label.new()
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.add_theme_color_override(&"font_color", Color(0.96, 0.92, 0.84))
	col.add_child(_text)
	_panel.modulate.a = 0.0


func _process(delta: float) -> void:
	# Hikâye sahnesi / diyalog sırasında beklet.
	if Cutscene.active != null or get_tree().paused:
		_panel.modulate.a = 0.0
		return
	if BattleArena.player_in_combat(get_tree()):
		if _calm <= 0.0 and _active and _held_now(_cur) and _age < _life * REQUEUE_BEFORE:
			_queue.push_front(_cur)
			_active = false
		_calm = CALM
	else:
		_calm = maxf(_calm - delta, 0.0)
	if not _active and not _queue.is_empty() and not _held(_queue[0]):
		var it: Array = _queue.pop_front()
		_cur = it
		_portrait.texture = PORTRAITS.get(it[0], PORTRAITS["telsiz"])
		_name.text = String(it[1])
		_name.add_theme_color_override(&"font_color", NAME_COLOR.get(it[0], NAME_COLOR["telsiz"]))
		_full = String(it[2])
		_shown = 0.0
		_hold = HOLD + _full.length() * 0.02
		_age = 0.0
		_life = _full.length() / CHARS_PER_SEC + _hold
		_active = true
		Sfx.play(&"checkpoint", 1.8, -12.0)
	if _active:
		_age += delta
		_slide = minf(_slide + delta * 6.0, 1.0)
		if _shown < _full.length():
			_shown += delta * CHARS_PER_SEC
			_text.text = _full.substr(0, int(_shown))
		else:
			_text.text = _full
			_hold -= delta
			if _hold <= 0.0:
				_active = false
	else:
		_slide = maxf(_slide - delta * 5.0, 0.0)
	_panel.modulate.a = _slide
	_panel.offset_top = 16 - (1.0 - _slide) * 40.0
	_panel.offset_bottom = 116 - (1.0 - _slide) * 40.0
