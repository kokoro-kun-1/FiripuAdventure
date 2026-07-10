extends Node

# Singleton for saving and loading game state.
# Access via get_node("/root/SaveGame") or get_tree().root.get_node("SaveGame")
# after adding to autoload in project.godot.

# Data to persist
var player_position : Vector3 = Vector3.ZERO
var player_rotation_y : float = 0.0
var collected_count : int = 0
var collected_names : Array[String] = []
var medal_obtained : bool = false
var world_completed : bool = false

# File path
const SAVE_PATH := "user://savegame.save"

# Signals
signal saved
signal loaded

func _ready() -> void:
    pass

# --- Public API ---

func save_game(level_root: Node) -> void:
    """Call this to persist current game state."""
    var player_node := level_root.get_node_or_null("Firipu")
    if player_node == null:
        push_warning("SaveGame: Could not find Firipu node.")
        return

    # Player transform
    player_position = player_node.global_transform.origin
    player_rotation_y = player_node.global_transform.basis.get_euler().y

    # Collectibles from group "collectible"
    var collected_list := []
    var collectible_nodes := get_tree().get_nodes_in_group("collectible")
    for node in collectible_nodes:
        if node is Node3D:
            # Consider collected if not visible or monitoring disabled
            if not node.visible or not node.is_monitoring():
                collected_list.append(node.label)  # label set in editor

    collected_names = collected_list
    collected_count = collected_list.size()

    # Medal and world completion from player (if available)
    if player_node.has_method("get_medal_obtained"):
        medal_obtained = player_node.get_medal_obtained()
    else:
        medal_obtained = false

    # World completed: true if medal obtained (adjust as needed)
    world_completed = medal_obtained

    emit_signal("saved")
    print("Saved game: pos=%s, collected=%d, medal=%s" % [player_position, collected_count, medal_obtained])

func load_game(level_root: Node) -> void:
    """Load saved state from file and apply to level."""
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        push_warning("SaveGame: No save file found at %s" % SAVE_PATH)
        return

    var json_string = file.get_as_text()
    file.close()

    var result = JSON.parse_string(json_string)
    if typeof(result) != TYPE_DICTIONARY:
        push_error("SaveGame: Corrupted save file.")
        return

    var data = result

    # Apply to player
    var player_node := level_root.get_node_or_null("Firipu")
    if player_node != null:
        player_node.global_transform = Transform3D(Basis(), data.get("player_position", Vector3.ZERO))
        # Restore rotation if desired
        var rot_y : float = data.get("player_rotation_y", 0.0)
        var current_basis : Basis = player_node.global_transform.basis
        var new_basis = Basis().rotated(Vector3.UP, deg_to_rad(rot_y))
        player_node.global_transform = Transform3D(new_basis, player_node.global_transform.origin)

        if player_node.has_method("set_collected"):
            player_node.set_collected(data.get("collected_count", 0))
        else:
            player_node.set("collected", data.get("collected_count", 0))

        if player_node.has_method("set_medal_obtained"):
            player_node.set_medal_obtained(data.get("medal_obtained", false))
        else:
            player_node.set("medal_obtained", data.get("medal_obtained", false))

    # Apply to level: hide collected collectibles
    var names_to_hide : Array[String] = data.get("collected_names", [])
    for node in get_tree().get_nodes_in_group("collectible"):
        if node is Node3D:
            var label_var = node.get("label")
            var label : String = label_var if typeof(label_var) == TYPE_STRING else ""
            if label in names_to_hide:
                node.visible = false
                node.set_monitoring(false)
                # Optionally mark as collected
                if node.has_method("set_collected"):
                    node.set_collected(true)
                else:
                    node.set("collected", true)

    # Set world completed flag on level if method exists
    if level_root.has_method("set_world_completed"):
        level_root.set_world_completed(data.get("world_completed", false))
    else:
        # fallback: set a variable if exists
        level_root.set("world_completed", data.get("world_completed", false))

    emit_signal("loaded")
    print("Loaded game from %s" % SAVE_PATH)

# --- Helper methods for debugging / quicksave/load ---

func get_save_data() -> Dictionary:
    """Return current internal data as a dictionary (for debugging)."""
    return {
        "player_position": player_position,
        "player_rotation_y": player_rotation_y,
        "collected_count": collected_count,
        "collected_names": collected_names.duplicate(),
        "medal_obtained": medal_obtained,
        "world_completed": world_completed
    }

func apply_data(data: Dictionary) -> void:
    """Apply a dictionary to internal state (used by quickload)."""
    player_position = data.get("player_position", Vector3.ZERO)
    player_rotation_y = data.get("player_rotation_y", 0.0)
    collected_count = data.get("collected_count", 0)
    collected_names = data.get("collected_names", []).duplicate()
    medal_obtained = data.get("medal_obtained", false)
    world_completed = data.get("world_completed", false)