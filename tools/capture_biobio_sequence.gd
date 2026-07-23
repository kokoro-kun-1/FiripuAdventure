extends SceneTree

const LEVEL_PATH := "res://scenes/levels/level_biobio_prototype.tscn"
const OUT_DIR := "res://art/qa/biobio"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	var packed := load(LEVEL_PATH) as PackedScene
	if packed == null:
		push_error("No se pudo cargar Biobío")
		quit(1)
		return
	root.size = Vector2i(1280, 720)
	var level := packed.instantiate()
	root.add_child(level)
	await process_frame
	await process_frame

	var player := level.get_node("Firipu") as Node3D
	var hud := level.get_node("HUD")
	hud.call("start_game")
	await process_frame

	var shots := {
		"01_sendero": Vector3(-432, 1, 0),
		"02_bosque_yuki": Vector3(-245, 1, 0),
		"03_rio_plataformas": Vector3(-65, 1, 0),
		"04_humedal_kira": Vector3(115, 1, 0),
		"05_robot": Vector3(285, 1, 0),
		"06_jefe": Vector3(380, 1, 0),
	}
	for label in shots:
		player.global_position = shots[label]
		await _settle_camera()
		await _capture(label)

	for name in ["Chinita", "Abejorro", "Libelula", "RanitaPequena"]:
		level.get_node(name).interact(player)
	await process_frame
	await _capture("05_diario_completo")

	var boss := level.get_node("BossCosmicBeetle")
	boss.set("phase", 3)
	boss.call("expose_core")
	boss.call("hit_by_environment_object", "Piedra")
	await process_frame
	level.call("_on_medal_area_body_entered", player)
	await process_frame
	await _capture("06_victoria")
	quit(0)

func _settle_camera() -> void:
	for i in range(120):
		await process_frame
		await physics_frame

func _capture(label: String) -> void:
	var image := root.get_texture().get_image()
	var path := OUT_DIR + "/" + label + ".png"
	var error := image.save_png(path)
	if error != OK:
		push_error("No se pudo guardar " + path)
	else:
		print("CAPTURE_OK ", path)
