extends Node

const TestUtils = preload("res://tests/test_utils.gd")
const TEST_NAME: String = "ONBOARDING_TEST"

var level: Node = null

func _ready() -> void:
    print(TEST_NAME, ": starting")
    level = TestUtils.load_main_level(self, TEST_NAME)
    if level == null:
        return
    call_deferred("_run_test")

func _run_test() -> void:
    await get_tree().process_frame

    var firipu: Node = TestUtils.firipu_node(level, self, TEST_NAME)
    var hud: Node = TestUtils.required_node(level, NodePath("HUD"), self, TEST_NAME, "HUD")
    if firipu == null or hud == null:
        return

    var start_panel: CanvasItem = hud.get_node_or_null("StartPanel") as CanvasItem
    var title_label: Label = hud.get_node_or_null("StartPanel/StartVBox/StartTitleLabel") as Label
    var world_label: Label = hud.get_node_or_null("StartPanel/StartVBox/StartWorldLabel") as Label
    var objective_label: Label = hud.get_node_or_null("StartPanel/StartVBox/StartObjectiveLabel") as Label
    var controls_label: Label = hud.get_node_or_null("StartPanel/StartVBox/StartControlsLabel") as Label
    var hint_label: Label = hud.get_node_or_null("StartPanel/StartVBox/StartHintLabel") as Label

    if start_panel == null or title_label == null or world_label == null or objective_label == null or controls_label == null or hint_label == null:
        TestUtils.fail(self, TEST_NAME, "onboarding labels are missing")
        return
    if not start_panel.visible:
        TestUtils.fail(self, TEST_NAME, "start panel should be visible initially")
        return
    if not bool(firipu.get("input_locked")):
        TestUtils.fail(self, TEST_NAME, "Firipu input should start locked")
        return

    var required_fragments: Array[String] = [
        "Firipu Adventure",
        "Biobío Silvestre",
        "registre 4 especies",
        "Medalla del Bosque y Río",
        "A/D",
        "W/S",
        "Espacio / A",
        "E / X",
        "Esc / Start",
        "Presione Enter"
    ]
    var joined_text: String = "\n".join([
        title_label.text,
        world_label.text,
        objective_label.text,
        controls_label.text,
        hint_label.text
    ])
    for fragment in required_fragments:
        if not joined_text.contains(fragment):
            TestUtils.fail(self, TEST_NAME, "onboarding missing fragment: %s" % fragment)
            return

    hud.call("start_game")
    await get_tree().process_frame
    if start_panel.visible:
        TestUtils.fail(self, TEST_NAME, "start panel did not hide after start")
        return
    if bool(firipu.get("input_locked")):
        TestUtils.fail(self, TEST_NAME, "Firipu input remained locked after start")
        return

    print(TEST_NAME, ": PASS")
    get_tree().quit(0)
