extends Node

const TestUtils = preload("res://tests/test_utils.gd")
const TEST_NAME: String = "VICTORY_SUMMARY_TEST"

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

    var total_collectibles: int = int(firipu.get("total_collectibles"))
    var collected_nodes: Array[Node] = TestUtils.collectible_nodes(get_tree())
    if collected_nodes.size() != total_collectibles:
        TestUtils.fail(self, TEST_NAME, "expected %d collectibles, found %d" % [total_collectibles, collected_nodes.size()])
        return

    for collectible in collected_nodes:
        collectible.call("interact", firipu)
        await get_tree().process_frame

    firipu.call("pick_environment_object", "Piedra de río")
    await get_tree().process_frame

    firipu.call("obtain_medal")
    await get_tree().process_frame

    var victory_panel: CanvasItem = hud.get_node_or_null("VictoryPanel") as CanvasItem
    if victory_panel == null or not victory_panel.visible:
        TestUtils.fail(self, TEST_NAME, "victory panel is not visible")
        return

    var title_label: Label = hud.get_node_or_null("VictoryPanel/VictoryVBox/VictoryTitleLabel") as Label
    var summary_label: Label = hud.get_node_or_null("VictoryPanel/VictoryVBox/VictorySummaryLabel") as Label
    var next_label: Label = hud.get_node_or_null("VictoryPanel/VictoryVBox/VictoryNextLabel") as Label
    var continue_button: Button = hud.get_node_or_null("VictoryPanel/VictoryVBox/VictoryButtons/ContinueButton") as Button
    var save_button: Button = hud.get_node_or_null("VictoryPanel/VictoryVBox/VictoryButtons/SaveButton") as Button
    var exit_button: Button = hud.get_node_or_null("VictoryPanel/VictoryVBox/VictoryButtons/ExitButton") as Button

    if title_label == null or summary_label == null or next_label == null:
        TestUtils.fail(self, TEST_NAME, "victory labels are missing")
        return
    if continue_button == null or save_button == null or exit_button == null:
        TestUtils.fail(self, TEST_NAME, "victory action buttons are missing")
        return

    var summary: String = summary_label.text
    var required_fragments: Array[String] = [
        "Resumen de aventura",
        "Diario de Naturaleza: 4/4 especies registradas",
        "Objeto final: Piedra de río",
        "Medalla del Bosque y Río del Biobío",
        "Región protegida: Biobío Silvestre",
        "Prototipo: 0.1"
    ]
    for fragment in required_fragments:
        if not summary.contains(fragment):
            TestUtils.fail(self, TEST_NAME, "summary missing fragment: %s" % fragment)
            return

    if not next_label.text.contains("próxima región"):
        TestUtils.fail(self, TEST_NAME, "next-step text is not clear")
        return

    var exit_requested := false
    hud.exit_requested.connect(func() -> void:
        exit_requested = true
    )

    exit_button.pressed.emit()
    if exit_requested:
        TestUtils.fail(self, TEST_NAME, "victory exit emitted without confirmation")
        return
    if exit_button.text != "Confirmar salida":
        TestUtils.fail(self, TEST_NAME, "victory exit button did not switch to confirmation text")
        return

    continue_button.pressed.emit()
    if exit_button.text != "Salir":
        TestUtils.fail(self, TEST_NAME, "victory exit confirmation was not reset by continue")
        return

    print(TEST_NAME, ": PASS")
    get_tree().quit(0)
