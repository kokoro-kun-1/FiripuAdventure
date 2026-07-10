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
        push_error("SaveGame: Could not open save file for writing at " 