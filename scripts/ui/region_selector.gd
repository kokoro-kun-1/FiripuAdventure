extends Control

@onready var regions_grid: GridContainer = $RegionsGrid
@onready var close_btn: Button = $CloseButton

var region_data: Array[Dictionary] = []

func _ready() -> void:
	close_btn.pressed.connect(_on_close_pressed)
	_load_regions_data()
	refresh()

func _load_regions_data() -> void:
	var file: FileAccess = FileAccess.open("res://data/regiones.json", FileAccess.READ)
	if file == null:
		push_error("No se pudo cargar regiones.json")
		return
	
	var text: String = file.get_as_text()
	file.close()
	
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("regiones.json no es un diccionario válido")
		return
	
	region_data = parsed.get("regions", [])

func refresh() -> void:
	# Limpiar grid
	for child in regions_grid.get_children():
		child.queue_free()
	
	if region_data.size() == 0:
		return
	
	# Obtener progreso global
	var global_progress: GlobalProgress = GlobalProgress
	var completed_worlds: Array[String] = [] if global_progress == null else global_progress.get_completed_worlds()
	var unlocked_worlds: Array[String] = ["biobio"] if global_progress == null else global_progress.get_unlocked_worlds()
	
	for i in range(region_data.size()):
		var region: Dictionary = region_data[i]
		var region_id: String = region.get("id", "")
		var world_name: String = region.get("world_name", "")
		var region_name: String = region.get("region_name", "")
		
		var is_unlocked: bool = region_id in unlocked_worlds
		var is_completed: bool = region_id in completed_worlds
		
		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(280, 100)
		btn.tooltip_text = "%s\n%s" % [region_name, region.get("main_environment", "")]
		
		var vbox: VBoxContainer = VBoxContainer.new()
		btn.add_child(vbox)
		
		var name_label: Label = Label.new()
		name_label.text = world_name
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 18)
		if is_completed:
			name_label.modulate = Color(0.4, 0.85, 0.4)
		elif is_unlocked:
			name_label.modulate = Color(1.0, 0.9, 0.3)
		else:
			name_label.modulate = Color(0.5, 0.5, 0.5)
		vbox.add_child(name_label)
		
		var region_label: Label = Label.new()
		region_label.text = region_name
		region_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		region_label.add_theme_font_size_override("font_size", 14)
		region_label.modulate = Color(0.7, 0.8, 0.9)
		vbox.add_child(region_label)
		
		var status_label: Label = Label.new()
		status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		status_label.add_theme_font_size_override("font_size", 12)
		if is_completed:
			status_label.text = "✓ Completado"
			status_label.modulate = Color(0.4, 0.85, 0.4)
		elif is_unlocked:
			status_label.text = "Disponible"
			status_label.modulate = Color(1.0, 0.9, 0.3)
		else:
			status_label.text = "Bloqueado"
			status_label.modulate = Color(0.5, 0.5, 0.5)
		vbox.add_child(status_label)
		
		btn.disabled = not is_unlocked
		btn.pressed.connect(_on_region_selected.bind(region_id))
		
		regions_grid.add_child(btn)

func _on_region_selected(region_id: String) -> void:
	var main_menu: Node = get_parent().get_parent() # MainMenu
	if main_menu.has_method("load_world"):
		main_menu.load_world(region_id)
	visible = false

func _on_close_pressed() -> void:
	visible = false