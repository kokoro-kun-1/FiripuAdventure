extends Node

const TestUtils = preload("res://tests/test_utils.gd")
const TEST_NAME: String = "COLLECTIBLE_TEST"

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

    var collectible: Node = TestUtils.first_collectible(get_tree(), self, TEST_NAME)
    if collectible == null:
        return

    var label: String = str(collectible.get("label"))
    print(TEST_NAME, ": selected=", label)

    collectible.call("interact", firipu)
    await get_tree().process_frame

    if collectible.visible:
        TestUtils.fail(self, TEST_NAME, "collectible stayed visible after interact")
        return

    sg.call("save_game", level)
    print(TEST_NAME, ": saved after collecting")

    firipu.call("set_collected", 0)
    TestUtils.reset_collectible(collectible)
    print(TEST_NAME, ": reset visible=", collectible.visible, " monitoring=", TestUtils.get_monitoring(collectible))

    sg.call("load_game", level)
    await get_tree().process_frame

    var after_visible: bool = bool(collectible.visible)
    var after_monitoring: bool = TestUtils.get_monitoring(collectible)
    var after_collected: int = int(firipu.call("get_collected"))
    print(TEST_NAME, ": after_load visible=", after_visible, " monitoring=", after_monitoring, " collected=", after_collected)

    if after_visible:
        TestUtils.fail(self, TEST_NAME, "loaded collectible is still visible")
        return
    if after_monitoring:
        TestUtils.fail(self, TEST_NAME, "loaded collectible is still monitoring")
        return
    if after_collected < 1:
        TestUtils.fail(self, TEST_NAME, "player collected count was not restored")
        return

    print(TEST_NAME, ": PASS")
    get_tree().quit(0)
