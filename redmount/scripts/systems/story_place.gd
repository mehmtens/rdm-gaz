## StoryPlace — mekân işareti: oyuncu ilk kez vardığında mekânın adını ve
## hikâyedeki yerini bildirir (HUD üst ortada kısa bir pankart gösterir).
##
## Oyunu durdurmaz. Bölüm betikleri tabelayla birlikte kurar; Main `entered`
## sinyalini HUD'a bağlar. Grup: "story_place".
class_name StoryPlace
extends Node2D

signal entered(title: String, story: String, accent: Color)

@export var title: String = ""
@export_multiline var story: String = ""
@export var accent: Color = Color("ffc857")
## Oyuncu bu yatay mesafeye girince tetiklenir (px).
@export var reach: float = 280.0

var _done := false


func _ready() -> void:
	add_to_group(&"story_place")


func _physics_process(_delta: float) -> void:
	if _done:
		return
	var player := get_tree().get_first_node_in_group(&"player") as Node2D
	if player == null or absf(player.global_position.x - global_position.x) > reach:
		return
	_done = true
	set_physics_process(false)
	entered.emit(title, story, accent)
