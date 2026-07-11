extends RefCounted

const MAIN_SCENE_PATH: String = "res://scenes/levels/level_biobio_prototype.tscn"
const SAVE_PATH: String = "user://savegame.save"

static func load_main_level(runner: Node, test_name: String, scene_path: String = MAIN_SCENE_PATH) -> Node:
    var main_scene: PackedScene = load(scene_path) as PackedScene
    if main_scene == null:
        fail(runner, test_name, "could not load main scene")
        return null

    var level: Node = main_scene.instantiate() as Node
    runner.add_child(level)
    return level

static func save_game_node(runner: Node, test_name: String) -> Node:
    var sg: Node = runner.get_node_or_null("/root/SaveGame") as Node
    if sg == null:
        fail(runner, test_name, "SaveGame autoload not found")
    return sg

static func firipu_node(level: Node, runner: Node, test_name: String) -> Node:
    var firipu: Node = level.get_node_or_null("Firipu") as Node
    if firipu == null:
        fail(runner, test_name, "Firipu node not found")
    return firipu

static func required_node(root: Node, path: NodePath, runner: Node, test_name: String, label: String) -> Node:
    var node: Node = root.get_node_or_null(path) as Node
    if node == null:
        fail(runner, test_name, "%s not found" % label)
    return node

static func remove_save_file() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

static func assert_save_file_exists(runner: Node, test_name: String, context: String) -> bool:
    if not FileAccess.file_exists(SAVE_PATH):
        fail(runner, test_name, "%s did not create %s" % [context, SAVE_PATH])
        return false
    return true

static func parse_save_file(runner: Node, test_name: String) -> Dictionary:
    var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        fail(runner, test_name, "could not open save file")
        return {}

    var text: String = file.get_as_text()
    file.close()
    var parsed = JSON.parse_string(text)
    if typeof(parsed) != TYPE_DICTIONARY:
        fail(runner, test_name, "saved file is not a dictionary")
        return {}
    return parsed as Dictionary

static func first_collectible(tree: SceneTree, runner: Node, test_name: String) -> Node:
    for node in tree.get_nodes_in_group("collectible"):
        if node is Area3D:
            return node as Node
    fail(runner, test_name, "no collectible found")
    return null

static func collectible_nodes(tree: SceneTree) -> Array[Node]:
    var result: Array[Node] = []
    for node in tree.get_nodes_in_group("collectible"):
        if node is Area3D:
            result.append(node as Node)
    return result

static func reset_collectible(collectible: Node) -> void:
    collectible.visible = true
    if collectible.has_method("set_monitoring"):
        collectible.call("set_monitoring", true)
    if has_property(collectible, "registered"):
        collectible.set("registered", false)
    if collectible.has_method("set_collected"):
        collectible.call("set_collected", false)
    elif has_property(collectible, "collected"):
        collectible.set("collected", false)

static func get_monitoring(node: Node) -> bool:
    if node is Area3D:
        return bool((node as Area3D).monitoring)
    return false

static func has_property(node: Node, property_name: String) -> bool:
    for property in node.get_property_list():
        if str(property.get("name", "")) == property_name:
            return true
    return false

static func fail(runner: Node, test_name: String, message: String) -> void:
    push_error("%s: %s" % [test_name, message])
    runner.get_tree().quit(1)
