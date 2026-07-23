extends Control

@onready var region_selector: Control = $RegionSelector
@onready var new_game_button: Button = $MainPanel/VBox/ButtonsVBox/NewGameButton
@onready var continue_button: Button = $MainPanel/VBox/ButtonsVBox/ContinueButton
@onready var selector_button: Button = $MainPanel/VBox/ButtonsVBox/RegionSelectButton
@onready var quit_button: Button = $MainPanel/VBox/ButtonsVBox/QuitButton

var current_region := "biobio"
var global_progress: Node

func _ready() -> void:
	global_progress = get_node_or_null("/root/GlobalProgress")
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	selector_button.pressed.connect(_on_selector_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	region_selector.visible = false
	_check_saved_progress()

func _check_saved_progress() -> void:
	if global_progress == null:
		continue_button.disabled = true
		return
	continue_button.disabled = global_progress.get_last_played_world() == ""

func _on_new_game_pressed() -> void:
	if global_progress != null:
		global_progress.reset_all()
	load_world("biobio")

func _on_continue_pressed() -> void:
	if global_progress == null:
		load_world("biobio")
		return
	var world_id: String = global_progress.get_last_played_world()
	load_world("biobio" if world_id == "" else world_id)

func _on_selector_pressed() -> void:
	region_selector.refresh()
	region_selector.visible = true
	region_selector.move_to_front()

func _on_quit_pressed() -> void:
	get_tree().quit()

func load_world(world_id: String) -> void:
	var scene_path := "res://scenes/levels/level_%s.tscn" % world_id
	if world_id == "biobio":
		scene_path = "res://scenes/levels/level_biobio_prototype.tscn"

	var packed_scene := load(scene_path) as PackedScene
	if packed_scene == null:
		push_error("No se pudo cargar la escena: " + scene_path)
		return

	current_region = world_id
	if global_progress != null:
		global_progress.register_world_start(world_id)
		global_progress.force_save()

	get_tree().root.add_child(packed_scene.instantiate())
	visible = false
