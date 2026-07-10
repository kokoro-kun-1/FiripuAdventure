extends Node

const SAVE_PATH := "user://savegame.save"
const SAVE_VERSION := 1

signal saved
signal loaded

var player_position: Vector3 = Vector3.ZERO
var player_rotation_y: float = 0.0
var collected_count: int = 0
var collected_names: Array[String] = []
var medal_obtained: bool = false
var world_completed: bool = false

func save_game(level_root: Node) -> void:
    var player_node := level_root.get_node_or_null("Firipu")
    if player_node == null:
        push_warning("SaveGame: Could not find Firipu node.")
        return

    player_position = player_node.global_position
    player_rotation_y = player_node.global_rotation.y

    collected_names = _get_collected_names()
    collected_count = collected_names.size()

    if player_node.has_method("get_medal_obtained"):
        medal_obtained = player_node.get_medal_obtained()
    else:
        medal_obtained = bool(player_node.get("medal_obtained"))

    world_completed = medal_obtained

    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        push_error("SaveGame: Could not open save file for writing at %s" % SAVE_PATH)
        return

    file.store_string(JSON.stringify(_get_file_data()))
    file.close()

    saved.emit()
    print("Saved game: pos=%s, collected=%d, medal=%s" % [player_position, collected_count, medal_obtained])

func load_game(level_root: Node) -> void:
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        push_warning("SaveGame: No save file found at %s" % SAVE_PATH)
        return

    var json_string := file.get_as_text()
    file.close()

    var parsed = JSON.parse_string(json_string)
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("SaveGame: Corrupted save file.")
        return

    var data: Dictionary = parsed
    if int(data.get("version", -1)) != SAVE_VERSION:
        push_warning("SaveGame: Save file version mismatch. Expected %d, got %d" % [SAVE_VERSION, int(data.get("version", -1))])
        return

    _apply_to_player(level_root, data)
    _apply_to_collectibles(data)
    _apply_to_level(level_root, data)

    loaded.emit()
    print("Loaded game from %s" % SAVE_PATH)

func get_save_data() -> Dictionary:
    return {
        "player_position": player_position,
        "player_rotation_y": player_rotation_y,
        "collected_count": collected_count,
        "collected_names": collected_names.duplicate(),
        "medal_obtained": medal_obtained,
        "world_completed": world_completed,
        "version": SAVE_VERSION
    }

func apply_data(data: Dictionary) -> void:
    player_position = _array_to_vector3(data.get("player_position", [0.0, 0.0, 0.0]))
    player_rotation_y = float(data.get("player_rotation_y", 0.0))
    collected_count = int(data.get("collected_count", 0))
    collected_names = _to_string_array(data.get("collected_names", []))
    medal_obtained = bool(data.get("medal_obtained", false))
    world_completed = bool(data.get("world_completed", false))

func _apply_to_player(level_root: Node, data: Dictionary) -> void:
    var player_node := level_root.get_node_or_null("Firipu")
    if player_node == null:
        push_warning("SaveGame: Could not find Firipu node while loading.")
        return

    var restored_position := _array_to_vector3(data.get("player_position", [0.0, 0.0, 0.0]))
    var restored_rotation_y := float(data.get("player_rotation_y", 0.0))
    player_node.global_position = restored_position
    player_node.global_rotation.y = restored_rotation_y

    var saved_collected := int(data.get("collected_count", 0))
    if player_node.has_method("set_collected"):
        player_node.set_collected(saved_collected)
    else:
        player_node.set("collected", saved_collected)

    var saved_medal := bool(data.get("medal_obtained", false))
    if player_node.has_method("set_medal_obtained"):
        player_node.set_medal_obtained(saved_medal)
    else:
        player_node.set("medal_obtained", saved_medal)

func _apply_to_collectibles(data: Dictionary) -> void:
    var names_to_hide := _to_string_array(data.get("collected_names", []))
    for node in get_tree().get_nodes_in_group("collectible"):
        if node is Node3D:
            var label_var = node.get("label")
            var label := label_var as String if typeof(label_var) == TYPE_STRING else ""
            if label in names_to_hide:
                node.visible = false
                if node.has_method("set_monitoring"):
                    node.set_monitoring(false)
                if node.has_method("set_collected"):
                    node.set_collected(true)
                else:
                    node.set("collected", true)

func _apply_to_level(level_root: Node, data: Dictionary) -> void:
    var completed := bool(data.get("world_completed", false))
    if level_root.has_method("set_world_completed"):
        level_root.set_world_completed(completed)
    else:
        level_root.set("world_completed", completed)

func _get_collected_names() -> Array[String]:
    var result: Array[String] = []
    for node in get_tree().get_nodes_in_group("collectible"):
        if node is Node3D and (not node.visible or not node.is_monitoring()):
            var label_var = node.get("label")
            if typeof(label_var) == TYPE_STRING:
                result.append(label_var)
    return result

func _get_file_data() -> Dictionary:
    return {
        "player_position": _vector3_to_array(player_position),
        "player_rotation_y": player_rotation_y,
        "collected_count": collected_count,
        "collected_names": collected_names.duplicate(),
        "medal_obtained": medal_obtained,
        "world_completed": world_completed,
        "version": SAVE_VERSION
    }

func _vector3_to_array(value: Vector3) -> Array[float]:
    return [value.x, value.y, value.z]

func _array_to_vector3(value) -> Vector3:
    if typeof(value) == TYPE_VECTOR3:
        return value
    if typeof(value) == TYPE_ARRAY and value.size() >= 3:
        return Vector3(float(value[0]), float(value[1]), float(value[2]))
    return Vector3.ZERO

func _to_string_array(value) -> Array[String]:
    var result: Array[String] = []
    if typeof(value) == TYPE_ARRAY:
        for item in value:
            if typeof(item) == TYPE_STRING:
                result.append(item)
    return result
