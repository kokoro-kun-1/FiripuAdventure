extends Control

@onready var region_selector: Control = $RegionSelector
@onready var start_btn: Button = $MainPanel/VBox/StartButton
@onready var continue_btn: Button = $MainPanel/VBox/ContinueButton
@onready var selector_btn: Button = $MainPanel/VBox/SelectorButton
@onready var exit_btn: Button = $MainPanel/VBox/ExitButton

var current_region: String = "biobio"
var global_progress: GlobalProgress = GlobalProgress

func _ready() -> void:
	# Conexiones
	start_btn.pressed.connect(_on_start_pressed)
	continue_btn.pressed.connect(_on_continue_pressed)
	selector_btn.pressed.connect(_on_selector_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	
	# Ocultar selector al inicio
	region_selector.visible = false
	
	# Verificar si hay progreso guardado
	_check_saved_progress()

func _check_saved_progress() -> void:
	if global_progress == null:
		continue_btn.disabled = true
		return
	
	# Verificar si hay al menos un mundo completado o con progreso
	var any_progress: bool = false
	for world_id in global_progress.get_all_progress().keys():
		var prog: Dictionary = global_progress.get_world_progress(world_id)
		if prog.get("completed", false) or prog.get("collectibles_count", 0) > 0:
			any_progress = true
			break
	
	continue_btn.disabled = not any_progress

func _on_start_pressed() -> void:
	load_world("biobio")

func _on_continue_pressed() -> void:
	# Cargar el último mundo jugado o el primer no completado
	if global_progress == null:
		load_world("biobio")
		return
	
	# Buscar el primer mundo no completado
	for world_id in global_progress.get_all_progress().keys():
		var prog: Dictionary = global_progress.get_world_progress(world_id)
		if not prog.get("completed", false):
			load_world(world_id)
			return
	
	# Si todos completados, ir al último
	var last_id: String = global_progress.get_all_progress().keys()[-1]
	load_world(last_id)

func _on_selector_pressed() -> void:
	region_selector.visible = true
	# Asegurar que el selector esté al frente
	region_selector.move_to_front()

func _on_exit_pressed() -> void:
	get_tree().quit()

func load_world(world_id: String) -> void:
	current_region = world_id
	# Cambiar la escena principal en project.godot no es viable en runtime
	# En su lugar, cargamos la escena del mundo aditivamente
	var scene_path: String = "res://scenes/levels/level_%s.tscn" % [world_id]
	
	# Si es biobio, usar la escena original
	if world_id == "biobio":
		scene_path = "res://scenes/levels/level_biobio_prototype.tscn"
	
	var packed_scene: PackedScene = load(scene_path)
	if packed_scene == null:
		push_error("No se pudo cargar la escena: " + scene_path)
		return
	
	var level: Node = packed_scene.instantiate()
	get_tree().root.add_child(level)
	
	# Ocultar menú principal
	visible = false
	
	# Registrar inicio de mundo en GlobalProgress
	if global_progress != null:
		global_progress.register_world_start(world_id)

func _on_region_selector_closed() -> void:
	# Se llama cuando se cierra el selector
	pass