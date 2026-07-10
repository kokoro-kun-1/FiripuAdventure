extends Node

const TestUtils = preload("res://tests/test_utils.gd")
const TEST_NAME: String = "UI_SAVE_LOAD_TEST"

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

    var firipu: Node = TestUtils.firipu_node(level, self, TEST_NAME)
    var hud: Node = TestUtils.required_node(level, "HUD", self, TEST_NAME, "HUD")
    if firipu == null or hud == null:
        return

    var save_button: Button = TestUtils.required_node(hud, "Panel/VBox/SaveLoadButtons/SaveButton", self, TEST_NAME, "save button") as Button
    var load_button: Button = TestUtils.required_node(hud, "Panel/VBox/SaveLoadButtons/LoadButton", self, TEST_NAME, "load button") as Button
    if save_button == null or load_button == null:
        return

    var collectible: Node = TestUtils.first_collectible(get_tree(), self, TEST_NAME)
    if collectible == null:
        return

    collectible.call("interact", firipu)
    await get_tree().process_frame

    save_button.pressed.emit()
    await get_tree().process_frame

    if not TestUtils.assert_save_file_exists(self, TEST_NAME, "save button"):
        return

    firipu.call("set_collected", 0)
    TestUtils.reset_collectible(collectible)

    load_button.pressed.emit()
    await get_tree().process_frame

    var loaded_collected: int = int(firipu.call("get_collected"))
    var loaded_visible: bool = bool(collectible.visible)
    print(TEST_NAME, ": loaded_collected=", loaded_collected, " visible=", loaded_visible)

    if loaded_collected != 1:
        TestUtils.fail(self, TEST_NAME, "load button did not restore collected count")
        return
    if loaded_visible:
        TestUtils.fail(self, TEST_NAME, "load button did not restore collectible visibility")
        return

    print(TEST_NAME, ": PASS")
    get_tree().quit(0)
