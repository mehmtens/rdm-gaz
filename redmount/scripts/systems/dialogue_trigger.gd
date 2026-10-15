## DialogueTrigger — oyuncu alana girince bir kez diyalog başlatır (Görev 24).
##
## `speakers` ve `texts` paralel dizilerdir (i. konuşmacı → i. replik). Main
## `triggered` sinyalini dinler, `DialogueBox`'a iletir ve süresince dünyayı
## duraklatır. `once` false ise her girişte tekrar oynar.
extends Area2D

signal triggered(lines: Array)

@export var speakers: PackedStringArray = []
@export_multiline var texts: PackedStringArray = []
@export var once: bool = true
## Bölüm içinde gerçekten bulunan hikâye nesnesi. Boşsa tetik görünmez kalır.
@export_enum("none", "cassette") var clue_visual: String = "none"

var _done := false
var _visual_time := 0.0


func _ready() -> void:
	add_to_group(&"dialogue_trigger")
	collision_layer = 0
	collision_mask = 2  # player
	body_entered.connect(_on_body_entered)
	set_process(clue_visual != "none")


func _process(delta: float) -> void:
	_visual_time += delta
	queue_redraw()


func _draw() -> void:
	if clue_visual != "cassette" or _done:
		return
	var bob := sin(_visual_time * 2.8) * 3.0
	draw_set_transform(Vector2(0, 8.0 + bob), -0.10, Vector2.ONE)
	# Piksel art kaset (assets/environment/pixel/kaset.png), 3x.
	var k := preload("res://assets/environment/pixel/kaset.png")
	draw_texture_rect(k, Rect2(-24, -16.5, 48, 33), false)


func _on_body_entered(body: Node) -> void:
	if _done or not body.is_in_group(&"player"):
		return
	if once:
		_done = true
		set_deferred(&"monitoring", false)
		queue_redraw()
	var lines: Array = []
	for i in texts.size():
		lines.append({
			"speaker": speakers[i] if i < speakers.size() else (speakers[-1] if speakers.size() > 0 else ""),
			"text": texts[i],
		})
	triggered.emit(lines)
