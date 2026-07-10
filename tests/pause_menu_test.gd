extends Node

const TestUtils = preload("res://tests/test_utils.gd")
const TEST_NAME: String = "PAUSE_MENU_TEST"

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

    var pause_panel: Panel = TestUtils.required_node(hud, "PausePanel", self, TEST_NAME, "pause panel") as Panel
    var continue_button: Button = TestUtils.required_node(hud, "PausePanel/PauseVBox/ContinueButton", self, TEST_NAME, "continue button") as Button
    var save_button: Button = TestUtils.required_node(hud, "PausePanel/PauseVBox/SaveButton", self, TEST_NAME, "pause save button") as Button
    var load_button: Button = TestUtils.required_node(hud, "PausePanel/PauseVBox/LoadButton", self, TEST_NAME, "pause load button") as Button
    var exit_button: Button = TestUtils.required_node(hud, "PausePanel/PauseVBox/ExitButton", self, TEST_NAME, "pause exit button") as Button
    if pause_panel == null or continue_button == null or save_button == null or load_button == null or exit_button == null:
        return

    if pause_panel.visible:
        TestUtils.fail(self, TEST_NAME, "pause panel should start hidden")
        return

    hud.call("start_game")
    hud.call("open_pause_menu")

    if not bool(hud.call("is_pause_menu_open")):
        TestUtils.fail(self, TEST_NAME, "pause menu did not open")
        return
    if not pause_panel.visible:
        TestUtils.fail(self, TEST_NAME, "pause panel not visible after open")
        return
    if not get_tree().paused:
        TestUtils.fail(self, TEST_NAME, "scene tree was not paused")
        return

    var initial_collected: int = int(firipu.call("get_collected"))
    save_button.pressed.emit()
    if not TestUtils.assert_save_file_exists(self, TEST_NAME, "pause save button"):
        get_tree().paused = false
        return

    firipu.call("set_collected", clampi(initial_collected + 1, 0, int(firipu.get("total_collectibles"))))
    load_button.pressed.emit()
    var loaded_collected: int = int(firipu.call("get_collected"))
    print(TEST_NAME, ": loaded_collected=", loaded_collected, " initial=", initial_collected)
    if loaded_collected != initial_collected:
        TestUtils.fail(self, TEST_NAME, "pause load button did not restore saved state")
        get_tree().paused = false
        return

    continue_button.pressed.emit()
    if bool(hud.call("is_pause_menu_open")):
        TestUtils.fail(self, TEST_NAME, "continue button did not close pause menu")
        get_tree().paused = false
        return
    if get_tree().paused:
        TestUtils.fail(self, TEST_NAME, "continue button did not unpause scene tree")
        get_tree().paused = false
        return

    var exit_requested := false
    hud.exit_requested.connect(func() -> void:
        exit_requested = true
    )

    hud.call("open_pause_menu")
    exit_button.pressed.emit()
    if exit_requested:
        TestUtils.fail(self, TEST_NAME, "pause exit emitted without confirmation")
        get_tree().paused = false
        return
    if exit_button.text != "Confirmar salida":
        TestUtils.fail(self, TEST_NAME, "pause exit button did not switch to confirmation text")
        get_tree().paused = false
        return

    continue_button.pressed.emit()
    if exit_button.text != "Salir del prototipo":
        TestUtils.fail(self, TEST_NAME, "pause exit confirmation was not reset by continue")
        get_tree().paused = false
        return

    print(TEST_NAME, ": PASS")
    get_tree().quit(0)
