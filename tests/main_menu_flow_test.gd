extends Node

const TEST_NAME := "MAIN_MENU_FLOW_TEST"
const MENU_SCENE := preload("res://scenes/ui/main_menu.tscn")

func _ready() -> void:
    print(TEST_NAME, ": starting")
    call_deferred("_run_test")

func _run_test() -> void:
    await get_tree().process_frame

    var progress := get_node_or_null("/root/GlobalProgress")
    if progress == null:
        _fail("GlobalProgress autoload not found")
        return

    progress.reset_all()
    var unlocked: Array[String] = progress.get_unlocked_worlds()
    var completed: Array[String] = progress.get_completed_worlds()
    if unlocked != ["biobio"]:
        _fail("fresh progress must unlock only biobio")
        return
    if not completed.is_empty():
        _fail("fresh progress must not contain completed worlds")
        return

    var menu := MENU_SCENE.instantiate()
    add_child(menu)
    await get_tree().process_frame

    var new_game := menu.get_node_or_null("MainPanel/VBox/ButtonsVBox/NewGameButton") as Button
    var continue_button := menu.get_node_or_null("MainPanel/VBox/ButtonsVBox/ContinueButton") as Button
    var selector_button := menu.get_node_or_null("MainPanel/VBox/ButtonsVBox/RegionSelectButton") as Button
    var selector := menu.get_node_or_null("RegionSelector") as Control
    if new_game == null or continue_button == null or selector_button == null or selector == null:
        _fail("required menu controls are missing")
        return
    if not continue_button.disabled:
        _fail("continue must be disabled with fresh progress")
        return
    if selector.visible:
        _fail("region selector must start hidden")
        return

    selector_button.pressed.emit()
    await get_tree().process_frame
    if not selector.visible:
        _fail("selector button did not open region selector")
        return

    var grid := selector.get_node_or_null("MainPanel/VBox/RegionsGrid") as GridContainer
    if grid == null or grid.get_child_count() != 16:
        _fail("region selector must build 16 region buttons")
        return

    var enabled_count := 0
    for child in grid.get_children():
        if child is Button and not (child as Button).disabled:
            enabled_count += 1
    if enabled_count != 1:
        _fail("fresh progress must enable exactly one region")
        return

    print(TEST_NAME, ": PASS")
    get_tree().quit(0)

func _fail(message: String) -> void:
    push_error(TEST_NAME + ": " + message)
    get_tree().quit(1)
