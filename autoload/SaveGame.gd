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
        push_error("SaveGame: Could not open save file for writing at " + SAVE_PATH)
        return

    var data := {
        "version": SAVE_VERSION,
        "player_position": [player_position.x, player_position.y, player_position.z],
        "player_rotation_y": player_rotation_y,
        "collected_count": collected_count,
        "collected_names": collected_names,
        "medal_obtained": medal_obtained,
        "world_completed": world_completed,
    }
    file.store_string(JSON.stringify(data))
    file.close()

    saved.emit()
    print("SaveGame: guardado en " + SAVE_PATH)

func load_game(level_root: Node = null) -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        push_warning("SaveGame: no existe partida guardada en " + SAVE_PATH)
        return {}

    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        push_error("SaveGame: Could not open save file for reading at " + SAVE_PATH)
        return {}

    var text := file.get_as_text()
    file.close()

    var parsed: Variant = JSON.parse_string(text)
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("SaveGame: archivo de guardado corrupto")
        return {}

    var data: Dictionary = parsed

    if int(data.get("version", 0)) != SAVE_VERSION:
        push_warning("SaveGame: versión de guardado distinta (%s)" % str(data.get("version")))
        return {}

    var pos: Array = data.get("player_position", [0.0, 0.0, 0.0])
    player_position = Vector3(float(pos[0]), float(pos[1]), float(pos[2]))
    player_rotation_y = float(data.get("player_rotation_y", 0.0))
    collected_names = Array(data.get("collected_names", []), TYPE_STRING, "", null)
    collected_count = int(data.get("collected_count", 0))
    medal_obtained = bool(data.get("medal_obtained", false))
    world_completed = bool(data.get("world_completed", false))

    if level_root != null:
        var player_node := level_root.get_node_or_null("Firipu")
        if player_node != null:
            player_node.global_position = player_position
            player_node.global_rotation.y = player_rotation_y
            if player_node.has_method("set_collected"):
                player_node.set_collected(collected_count)
            elif player_node.has_property("collected"):
                player_node.set("collected", collected_count)
            if player_node.has_method("set_medal_obtained"):
                player_node.set_medal_obtained(medal_obtained)
        # Hide collectibles that were already registered
        for node in get_tree().get_nodes_in_group("collectible"):
            if node.has_method("get") and collected_names.has(str(node.get("label"))):
                node.visible = false
                if node.has_method("set"):
                    node.set("registered", true)
                if node.has_method("set_deferred"):
                    node.set_deferred("monitoring", false)
        # Restore world completed state on the level
        if world_completed and level_root.has_method("set_world_completed"):
            level_root.set_world_completed(true)

    loaded.emit()
    print("SaveGame: cargada partida desde " + SAVE_PATH)
    return data

func get_save_data() -> Dictionary:
    return {
        "version": SAVE_VERSION,
        "player_position": [player_position.x, player_position.y, player_position.z],
        "player_rotation_y": player_rotation_y,
        "collected_count": collected_count,
        "collected_names": collected_names,
        "medal_obtained": medal_obtained,
        "world_completed": world_completed,
    }

func has_save() -> bool:
    return FileAccess.file_exists(SAVE_PATH)

func reset_save() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(SAVE_PATH)
    player_position = Vector3.ZERO
    player_rotation_y = 0.0
    collected_count = 0
    collected_names = []
    medal_obtained = false
    world_completed = false
    print("SaveGame: partida reiniciada")

func _get_collected_names() -> Array[String]:
    var result: Array[String] = []
    for node in get_tree().get_nodes_in_group("collectible"):
        if node.get("registered") == true:
            var name := String(node.get("label"))
            if name != "" and not result.has(name):
                result.append(name)
    return result
