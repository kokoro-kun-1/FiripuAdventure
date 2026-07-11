extends Node

const TestUtils = preload("res://tests/test_utils.gd")
const TEST_NAME: String = "DIARY_TEST"

var level: Node = null

func _ready() -> void:
    print(TEST_NAME, ": starting")
    level = TestUtils.load_main_level(self, TEST_NAME)
    if level == null:
        return
    call_deferred("_run_test")

func _run_test() -> void:
    await get_tree().process_frame

    var hud: Node = level.get_node_or_null("HUD")
    var firipu: Node = TestUtils.firipu_node(level, self, TEST_NAME)
    if hud == null or firipu == null:
        TestUtils.fail(self, TEST_NAME, "faltan hud o firipu")
        return

    # Recolectar las 4 especies del nivel.
    var collected := TestUtils.collectible_nodes(get_tree())
    if collected.size() < 4:
        TestUtils.fail(self, TEST_NAME, "se esperaban 4 coleccionables, hay %d" % collected.size())
        return

    for c in collected:
        c.call("interact", firipu)
    await get_tree().process_frame

    # El HUD debe marcar las 4 entradas del Diario.
    var marcadas := 0
    for name in ["DiaryChinita", "DiaryAbejorro", "DiaryLibelula", "DiaryRanita"]:
        var lbl: Node = hud.get_node_or_null("DiaryPanel/DiaryVBox/" + name)
        if lbl == null:
            TestUtils.fail(self, TEST_NAME, "falta nodo %s en el HUD" % name)
            return
        if lbl.text.begins_with("✓"):
            marcadas += 1
        else:
            print(TEST_NAME, ": entrada no marcada: ", name, " -> ", lbl.text)

    if marcadas != 4:
        TestUtils.fail(self, TEST_NAME, "solo %d/4 especies marcadas en el Diario" % marcadas)
        return

    print(TEST_NAME, ": PASS")
    get_tree().quit(0)
