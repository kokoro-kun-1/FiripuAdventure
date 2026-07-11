extends Node

const TestUtils = preload("res://tests/test_utils.gd")
const TEST_NAME: String = "NUBLE_TEST"
const NUBLE_SCENE := "res://scenes/levels/level_nuble.tscn"

var level: Node = null

func _ready() -> void:
    print(TEST_NAME, ": starting")
    var scene: PackedScene = load(NUBLE_SCENE) as PackedScene
    if scene == null:
        TestUtils.fail(self, TEST_NAME, "no se pudo cargar level_nuble.tscn")
        return
    level = scene.instantiate()
    add_child(level)
    call_deferred("_run_test")

func _run_test() -> void:
    await get_tree().process_frame

    var firipu: Node = level.get_node_or_null("Firipu")
    var boss: Node = level.get_node_or_null("HuemulGuardian")
    if firipu == null or boss == null:
        TestUtils.fail(self, TEST_NAME, "faltan Firipu o HuemulGuardian")
        return

    # 4 especies coleccionables.
    var collected := TestUtils.collectible_nodes(get_tree())
    if collected.size() < 4:
        TestUtils.fail(self, TEST_NAME, "se esperaban 4 coleccionables, hay %d" % collected.size())
        return

    # Mecánica de vapor termal: al entrar en vapor, Firipu recibe empuje hacia arriba.
    if not firipu.has_method("set_in_steam"):
        TestUtils.fail(self, TEST_NAME, "Firipu sin set_in_steam")
        return
    firipu.call("set_in_steam", true)
    if not bool(firipu.call("is_in_steam")):
        TestUtils.fail(self, TEST_NAME, "vapor no se activó")
        return
    var y0: float = firipu.global_position.y
    firipu.set("input_locked", false)
    # Simula varios frames de física con el vapor activo.
    for _i in 30:
        await get_tree().physics_frame
    var y1: float = firipu.global_position.y
    if y1 <= y0:
        TestUtils.fail(self, TEST_NAME, "el vapor termal no elevó a Firipu (y0=%.2f y1=%.2f)" % [y0, y1])
        return
    firipu.call("set_in_steam", false)

    print(TEST_NAME, ": PASS")
    get_tree().quit(0)
