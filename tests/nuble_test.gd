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

    # Mecanica de vapor termal: al entrar en vapor, Firipu recibe empuje hacia arriba.
    if not firipu.has_method("set_in_steam"):
        TestUtils.fail(self, TEST_NAME, "Firipu sin set_in_steam")
        return
    firipu.call("set_in_steam", true)
    if not bool(firipu.call("is_in_steam")):
        TestUtils.fail(self, TEST_NAME, "vapor no se activo")
        return
    var y0: float = firipu.global_position.y
    firipu.set("input_locked", false)
    # Simula varios frames de fisica con el vapor activo.
    for _i in 30:
        await get_tree().physics_frame
    var y1: float = firipu.global_position.y
    if y1 <= y0:
        TestUtils.fail(self, TEST_NAME, "el vapor termal no elevo a Firipu (y0=%.2f y1=%.2f)" % [y0, y1])
        return
    firipu.call("set_in_steam", false)

    # Las 4 especies de la escena deben coincidir con regiones.json (Nuble).
    var expected: Array[String] = _nuble_collectibles()
    if expected.is_empty():
        TestUtils.fail(self, TEST_NAME, "no se pudieron leer las especies de regiones.json")
        return
    var actual: Array[String] = []
    for c in collected:
        actual.append(String(c.get("label")))
    if actual.size() != expected.size():
        TestUtils.fail(self, TEST_NAME, "conteo de especies distinto al JSON")
        return
    for e in expected:
        if not actual.has(e):
            TestUtils.fail(self, TEST_NAME, "especie faltante o mal etiquetada: %s (escena: %s)" % [e, str(actual)])
            return

    # La medalla NO debe otorgarse sin Diario completo ni jefe derrotado.
    firipu.set("collected", 0)
    boss.set("defeated", false)
    if firipu.has_method("set_medal_obtained"):
        firipu.set_medal_obtained(false)
    level.call("_on_medal_area_body_entered", firipu)
    await get_tree().process_frame
    if bool(firipu.get("medal_obtained")):
        TestUtils.fail(self, TEST_NAME, "medalla otorgada sin requisitos (bug de Nuble)")
        return
    # Con Diario completo y jefe derrotado, si debe otorgarse.
    firipu.set("collected", 4)
    boss.set("defeated", true)
    level.call("_on_medal_area_body_entered", firipu)
    await get_tree().process_frame
    if not bool(firipu.get("medal_obtained")):
        TestUtils.fail(self, TEST_NAME, "medalla no se otorga con requisitos cumplidos")
        return

    print(TEST_NAME, ": PASS")
    get_tree().quit(0)

func _nuble_collectibles() -> Array[String]:
    var result: Array[String] = []
    var file: FileAccess = FileAccess.open("res://data/regiones.json", FileAccess.READ)
    if file == null:
        return result
    var text: String = file.get_as_text()
    file.close()
    var parsed: Variant = JSON.parse_string(text)
    if typeof(parsed) != TYPE_DICTIONARY:
        return result
    for region in parsed.regions:
        if String(region.get("id", "")) == "nuble":
            for sp in region.get("collectibles", []):
                result.append(String(sp))
            break
    return result
