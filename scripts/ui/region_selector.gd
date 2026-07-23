extends Control

@onready var regions_grid: GridContainer = $MainPanel/VBox/RegionsGrid
@onready var back_button: Button = $MainPanel/VBox/BackButton

var region_data: Array = []
var global_progress: Node

func _ready() -> void:
	global_progress = get_node_or_null("/root/GlobalProgress")
	back_button.pressed.connect(_on_back_pressed)
	_load_regions_data()
	refresh()

func _load_regions_data() -> void:
	var file := FileAccess.open("res://data/regiones.json", FileAccess.READ)
	if file == null:
		push_error("No se pudo cargar regiones.json")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("regiones.json no es un diccionario válido")
		return
	region_data = parsed.get("regions", [])

func refresh() -> void:
	if not is_node_ready():
		return
	for child in regions_grid.get_children():
		child.free()

	var unlocked: Array[String] = ["biobio"]
	var completed: Array[String] = []
	if global_progress != null:
		unlocked = global_progress.get_unlocked_worlds()
		completed = global_progress.get_completed_worlds()

	for region_value in region_data:
		var region := region_value as Dictionary
		var region_id := String(region.get("id", ""))
		var button := Button.new()
		button.custom_minimum_size = Vector2(260, 86)
		button.text = _button_text(region, completed.has(region_id))
		button.tooltip_text = "%s\n%s" % [region.get("region_name", ""), region.get("main_environment", "")]
		button.disabled = not unlocked.has(region_id)
		button.pressed.connect(_on_region_selected.bind(region_id))
		regions_grid.add_child(button)

func _button_text(region: Dictionary, completed: bool) -> String:
	var status := "Completado" if completed else "Disponible"
	return "%s\n%s" % [region.get("world_name", ""), status]

func _on_region_selected(region_id: String) -> void:
	var main_menu := get_parent()
	if main_menu.has_method("load_world"):
		main_menu.load_world(region_id)
	visible = false

func _on_back_pressed() -> void:
	visible = false
