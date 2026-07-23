extends Node
class_name GlobalProgress

## Estado global persistente entre sesiones

signal world_unlocked(world_id: String)
signal world_completed(world_id: String)
signal collectible_registered(world_id: String, label: String)
signal medal_obtained(world_id: String)

const SAVE_PATH := "user://global_progress.save"

## Estructura de datos por mundo
## {
##   "unlocked": bool,
##   "completed": bool,
##   "collectibles": { "label": bool },  # registrados
##   "medal": bool
## }

var _data: Dictionary = {}
var _dirty: bool = false
var _last_played_world := ""

func _ready() -> void:
	load_progress()
	_ensure_all_worlds_exist()

func _ensure_all_worlds_exist() -> void:
	var regions_data: Array = _load_regions_json()
	for region in regions_data:
		var id: String = region.id
		if not _data.has(id):
			_data[id] = {
				"unlocked": id == "biobio",  # solo Biobío desbloqueado al inicio
				"completed": false,
				"collectibles": {},
				"medal": false
			}
			_dirty = true
	if _dirty:
		save_progress()

func _load_regions_json() -> Array:
	var file: FileAccess = FileAccess.open("res://data/regiones.json", FileAccess.READ)
	if file == null:
		push_error("GlobalProgress: no se pudo leer regiones.json")
		return []
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return []
	return parsed.regions

## API pública

func is_unlocked(world_id: String) -> bool:
	return _data.get(world_id, {}).get("unlocked", false)

func is_completed(world_id: String) -> bool:
	return _data.get(world_id, {}).get("completed", false)

func get_collectibles_registered(world_id: String) -> Dictionary:
	return _data.get(world_id, {}).get("collectibles", {})

func has_medal(world_id: String) -> bool:
	return _data.get(world_id, {}).get("medal", false)

func get_world_progress(world_id: String) -> Dictionary:
	var d: Dictionary = _data.get(world_id, {})
	return {
		"unlocked": d.get("unlocked", false),
		"completed": d.get("completed", false),
		"collectibles_count": d.get("collectibles", {}).size(),
		"collectibles_total": 4,
		"medal": d.get("medal", false)
	}

func get_all_progress() -> Dictionary:
	return _data.duplicate(true)

func get_unlocked_worlds() -> Array[String]:
	var result: Array[String] = []
	for region in _load_regions_json():
		var world_id := String(region.get("id", ""))
		if is_unlocked(world_id):
			result.append(world_id)
	return result

func get_completed_worlds() -> Array[String]:
	var result: Array[String] = []
	for region in _load_regions_json():
		var world_id := String(region.get("id", ""))
		if is_completed(world_id):
			result.append(world_id)
	return result

func get_last_played_world() -> String:
	return _last_played_world

## Llamadas desde niveles

func register_world_start(world_id: String) -> void:
	if not _data.has(world_id):
		_data[world_id] = {"unlocked": true, "completed": false, "collectibles": {}, "medal": false}
	else:
		_data[world_id].unlocked = true
	_last_played_world = world_id
	_dirty = true

func register_collectible(world_id: String, label: String) -> void:
	if not _data.has(world_id):
		register_world_start(world_id)
	var coll: Dictionary = _data[world_id].collectibles
	if not coll.has(label):
		coll[label] = true
		_dirty = true
		collectible_registered.emit(world_id, label)

func register_medal(world_id: String) -> void:
	if not _data.has(world_id):
		register_world_start(world_id)
	if not _data[world_id].medal:
		_data[world_id].medal = true
		_dirty = true
		medal_obtained.emit(world_id)

func complete_world(world_id: String) -> void:
	if not _data.has(world_id):
		register_world_start(world_id)
	
	var was_completed: bool = _data[world_id].completed
	_data[world_id].completed = true
	_data[world_id].medal = true
	
	## Desbloquear siguiente región en orden lineal
	var regions: Array = _load_regions_json()
	for i in regions.size():
		if regions[i].id == world_id and i + 1 < regions.size():
			var next_id: String = regions[i + 1].id
			if _data.has(next_id) and not _data[next_id].unlocked:
				_data[next_id].unlocked = true
				world_unlocked.emit(next_id)
			break
	
	if not was_completed:
		_dirty = true
		world_completed.emit(world_id)

## Persistencia

func save_progress() -> void:
	if not _dirty:
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("GlobalProgress: no se pudo guardar en " + SAVE_PATH)
		return
	file.store_string(JSON.stringify({
		"worlds": _data,
		"last_played_world": _last_played_world,
	}, "	"))
	file.close()
	_dirty = false
	print("GlobalProgress: guardado en " + SAVE_PATH)

func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("GlobalProgress: sin archivo previo, inicio fresco")
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("GlobalProgress: no se pudo leer " + SAVE_PATH)
		return
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) == TYPE_DICTIONARY:
		if parsed.has("worlds"):
			_data = parsed.get("worlds", {})
			_last_played_world = String(parsed.get("last_played_world", ""))
		else:
			# Migración transparente del formato anterior.
			_data = parsed
			_last_played_world = ""
		print("GlobalProgress: cargado desde " + SAVE_PATH)
	else:
		push_error("GlobalProgress: archivo corrupto")

## Utilidades

func reset_all() -> void:
	_data.clear()
	_last_played_world = ""
	_dirty = true
	_ensure_all_worlds_exist()
	save_progress()

func force_save() -> void:
	_dirty = true
	save_progress()

## Limpieza al salir

func _on_exit_tree() -> void:
	if _dirty:
		save_progress()