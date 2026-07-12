extends Button

@export var region_id: String = ""

func _ready() -> void:
	# El texto y estado se configuran desde RegionSelector
	pass

func setup(region_info: Dictionary, is_unlocked: bool, is_completed: bool) -> void:
	region_id = region_info.get("id", "")
	
	var vbox: VBoxContainer = VBoxContainer.new()
	add_child(vbox)
	
	var name_label: Label = Label.new()
	name_label.text = region_info.get("world_name", "")
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(name_label)
	
	var region_label: Label = Label.new()
	region_label.text = region_info.get("region_name", "")
	region_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	region_label.add_theme_font_size_override("font_size", 14)
	region_label.modulate = Color(0.7, 0.8, 0.9)
	vbox.add_child(region_label)
	
	var status_label: Label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 12)
	
	if false: # is_completed - se pasa desde afuera
		status_label.text = "✓ Completado"
		status_label.modulate = Color(0.4, 0.85, 0.4)
	elif true: # is_unlocked
		status_label.text = "Disponible"
		status_label.modulate = Color(1.0, 0.9, 0.3)
	else:
		status_label.text = "Bloqueado"
		status_label.modulate = Color(0.5, 0.5, 0.5)
	vbox.add_child(status_label)