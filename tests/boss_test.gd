extends Node

const TestUtils = preload("res://tests/test_utils.gd")
const TEST_NAME: String = "BOSS_TEST"

var level: Node = null

func _ready() -> void:
    print(TEST_NAME, ": starting")
    level = TestUtils.load_main_level(self, TEST_NAME)
    if level == null:
        return
    call_deferred("_run_test")

func _run_test() -> void:
    await get_tree().process_frame

    var boss: Node = level.get_node_or_null("BossCosmicBeetle")
    if boss == null:
        TestUtils.fail(self, TEST_NAME, "BossCosmicBeetle no encontrado en el nivel")
        return
    if not boss.has_method("expose_core"):
        TestUtils.fail(self, TEST_NAME, "boss no tiene expose_core")
        return

    # Fase inicial debe ser CARGA (1)
    if int(boss.get("phase")) != 1:
        TestUtils.fail(self, TEST_NAME, "fase inicial no es CARGA (1)")
        return

    # Forzar fase de nucleo para validar el flujo de debilidad.
    boss.set("phase", 3)
    boss.set("_phase_timer", 999.0)
    await get_tree().process_frame

    # Yuki detecta el punto debil -> expone nucleo
    var yuki: Node = level.get_node_or_null("Yuki")
    if yuki != null and yuki.has_method("detect_weakness"):
        yuki.call("detect_weakness", boss)
        await get_tree().process_frame

    if not bool(boss.get("core_exposed")):
        TestUtils.fail(self, TEST_NAME, "nucleo no fue expuesto por Yuki")
        return

    # Firipu usa una piedra contra el nucleo -> derrota
    boss.call("hit_by_environment_object", "Piedra")
    await get_tree().process_frame

    if not bool(boss.get("defeated")):
        TestUtils.fail(self, TEST_NAME, "jefe no fue derrotado tras golpe en nucleo")
        return

    # Un segundo golpe no debe romper nada
    boss.call("hit_by_environment_object", "Rama")
    await get_tree().process_frame

    print(TEST_NAME, ": PASS")
    get_tree().quit(0)
