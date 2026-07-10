extends Node

const TestUtils = preload("res://tests/test_utils.gd")
const TEST_NAME: String = "SAVE_TEST"

var level: Node = null

func _ready() -> void:
    print(TEST_NAME, ": starting")
    level = TestUtils.load_main_level(self, TEST_NAME)
    if level == null:
        return
    call_deferred("_run_test")

func _run_test() -> void:
    await get_tree().process_frame

    var sg: Node = TestUtils.save_game_node(self, TEST_NAME)
    var firipu: Node = TestUtils.firipu_node(level, self, TEST_NAME)
    if sg == null or firipu == null:
        return

    TestUtils.remove_save_file()

    var initial_collected: int = int(firipu.call("get_collected"))
    var total_collectibles: int = int(firipu.get("total_collectibles"))
    print(TEST_NAME, ": initial_collected=", initial_collected, "/", total_collectibles)

    sg.call("save_game", level)
    if not TestUtils.assert_save_file_exists(self, TEST_NAME, "save_game"):
        return

    var changed_collected: int = clampi(initial_collected + 1, 0, total_collectibles)
    firipu.call("set_collected", changed_collected)
    print(TEST_NAME, ": changed_collected=", int(firipu.call("get_collected")))

    sg.call("load_game", level)
    var loaded_collected: int = int(firipu.call("get_collected"))
    print(TEST_NAME, ": loaded_collected=", loaded_collected)

    var data: Dictionary = sg.call("get_save_data") as Dictionary
    var version: int = int(data.get("version", -1))
    print(TEST_NAME, ": version=", version)

    if loaded_collected != initial_collected:
        TestUtils.fail(self, TEST_NAME, "loaded_collected does not match initial_collected")
        return

    if version != 1:
        TestUtils.fail(self, TEST_NAME, "save version is not 1")
        return

    print(TEST_NAME, ": PASS")
    get_tree().quit(0)
