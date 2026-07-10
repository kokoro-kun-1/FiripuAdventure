extends SceneTree

func _initialize() -> void:
	var scene: PackedScene = load("res://scenes/levels/level_biobio_prototype.tscn")
	if scene == null:
		push_error("No se pudo cargar escena Biobío")
		quit(1)
		return
	var level: Node = scene.instantiate()
	root.add_child(level)
	root.size = Vector2i(1280, 720)
	await process_frame
	await process_frame
	await process_frame
	var img: Image = root.get_texture().get_image()
	if img == null or img.is_empty():
		push_error("No se pudo capturar viewport")
		quit(1)
		return
	var path := "/tmp/firipu_biobio_25d_godot.png"
	var err := img.save_png(path)
	if err != OK:
		push_error("No se pudo guardar captura: %s" % err)
		quit(1)
		return
	print("SCREENSHOT_OK %s" % path)
	quit(0)
