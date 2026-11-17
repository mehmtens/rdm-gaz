## Coin — standart coin (Görev 4). Skor + mağaza parası (ana plan md. 11.1).
extends PickupBase

@export var value: int = 1

## Coin zinciri (tur 265 ses denetimi): `CHAIN_WINDOW_MS` içinde art arda toplanan her coin
## majör gamda bir basamak yukarı çalar; tepeye (bir oktav) varınca orada kalır, ara verilince
## başa döner. Mıknatıslı coin dizisi tek düze "tık tık" yerine dolan bir ezgi verir.
const CHAIN_WINDOW_MS := 400
const CHAIN_STEPS: PackedInt32Array = [0, 2, 4, 5, 7, 9, 11, 12]
static var _chain_n: int = -1
static var _chain_ms: int = -100000


## Bu anda toplanan coinin perdesini döndürür ve zinciri ilerletir.
static func chain_pitch(now_ms: int) -> float:
	if now_ms - _chain_ms <= CHAIN_WINDOW_MS:
		_chain_n = mini(_chain_n + 1, CHAIN_STEPS.size() - 1)
	else:
		_chain_n = 0
	_chain_ms = now_ms
	return pow(2.0, float(CHAIN_STEPS[_chain_n]) / 12.0)


func _ready() -> void:
	# Tek ve okunaklı ekonomi: her coin aynı görünür ve aynı değeri verir.
	# Değer 2: yükseltme fiyatlarına bölüm başına daha hızlı ulaşılır.
	value = 2
	kind = "coin"
	super()
	add_to_group(&"coin")


func _collect(_player: Node) -> void:
	GameState.add_coins(value)
	Sfx.play(&"coin", chain_pitch(Time.get_ticks_msec()), 0.0, false)
	Fx.spark(global_position, Vector2.ZERO, 5, Color(1, 0.9, 0.5), 0.7)
