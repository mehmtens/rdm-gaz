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
	var turquoise := Color("43d7c2")
	draw_circle(Vector2.ZERO, 28.0, Color(turquoise, 0.10))
	draw_rect(Rect2(-22, -14, 44, 28), Color("17162b"))
	draw_rect(Rect2(-19, -11, 38, 22), Color("ddd5c5"))
	draw_rect(Rect2(-16, -8, 32, 7), turquoise)
	draw_circle(Vector2(-9, 4), 6.0, Color("34364a"))
	draw_circle(Vector2(9, 4), 6.0, Color("34364a"))
	draw_circle(Vector2(-9, 4), 2.2, Color("f4c95d"))
	draw_circle(Vector2(9, 4), 2.2, Color("f4c95d"))
	draw_line(Vector2(-7, 4), Vector2(7, 4), Color("8a5d3b"), 2.0)


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
