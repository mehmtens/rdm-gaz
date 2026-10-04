extends Node
func _ready() -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://_showcase/fade_00.png")
	await get_tree().create_timer(0.12).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://_showcase/fade_01.png")
	await get_tree().create_timer(0.4).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://_showcase/fade_02.png")
	get_tree().quit()
