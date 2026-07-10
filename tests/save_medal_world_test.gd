extends Node

const TestUtils = preload("res://tests/test_utils.gd")
const TEST_NAME: String = "MEDAL_WORLD_TEST"

var level: Node = null

func _ready() -> void:
    print(TEST_NAME, ": starting")
    level = TestUtils.load_main_level(self, TEST_NAME)
    if level == null:
        return
    call_deferred("_run_test")

func _run_test() -> void:
    await get_tree().process_frame

    TestUtils.remove_save_file()

    var sg: Node = TestUtils.save_game_node(self, TEST_NAME)
    var firipu: Node = TestUtils.firipu_node(level, self, TEST_NAME)
    if sg == null or firipu == null:
        return

    var total_collectibles: int = int(firipu.get("total_collectibles"))
    var collected_nodes: Array[Node] = TestUtils.collectible_nodes(get_tree())

    if collected_nodes.size() != total_collectibles:
        TestUtils.fail(self, TEST_NAME, "expected %d collectibles, found %d" % [total_collectibles, collected_nodes.size()])
        return

    for collectible in collected_nodes:
        collectible.call("interact", firipu)
        await get_tree().process_frame

    firipu.call("obtain_medal")
    await get_tree().process_frame

    var medal_before_save: bool = bool(firipu.call("get_medal_obtained"))
    var world_before_save: bool = bool(level.call("get_world_completed"))
    print(TEST_NAME, ": before_save medal=", medal_before_save, " world=", world_before_save)

    if not medal_before_save:
        TestUtils.fail(self, TEST_NAME, "medal was not obtained before save")
        return
    if not world_before_save:
        TestUtils.fail(self, TEST_NAME, "world was not completed before save")
        return

    sg.call("save_game", level)
    await get_tree().process_frame

    if not TestUtils.assert_save_file_exists(self, TEST_NAME, "save_game"):
        return

    var data: Dictionary = TestUtils.parse_save_file(self, TEST_NAME)
    if data.is_empty():
        return
    if not bool(data.get("medal_obtained", false)):
        TestUtils.fail(self, TEST_NAME, "save file did not store medal_obtained=true")
        return
    if not bool(data.get("world_completed", false)):
        TestUtils.fail(self, TEST_NAME, "save file did not store world_completed=true")
        return

    firipu.call("set_collected", 0)
    firipu.call("set_medal_obtained", false)
    level.call("set_world_completed", false)
    await get_tree().process_frame

    sg.call("load_game", level)
    await get_tree().process_frame

    var medal_after_load: bool = bool(firipu.call("get_medal_obtained"))
    var world_after_load: bool = bool(level.call("get_world_completed"))
    var collected_after_load: int = int(firipu.call("get_collected"))
    print(TEST_NAME, ": after_load medal=", medal_after_load, " world=", world_after_load, " collected=", collected_after_load)

    if not medal_after_load:
        TestUtils.fail(self, TEST_NAME, "medal was not restored")
        return
    if not world_after_load:
        TestUtils.fail(self, TEST_NAME, "world completed state was not restored")
        return
    if collected_after_load != total_collectibles:
        TestUtils.fail(self, TEST_NAME, "collected count was not restored to total")
        return

    print(TEST_NAME, ": PASS")
    get_tree().quit(0)
