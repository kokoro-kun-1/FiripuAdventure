extends Node

const TestUtils = preload("res://tests/test_utils.gd")
const TEST_NAME: String = "VALPARAISO_TEST"
const VALPARAISO_SCENE := "res://scenes/levels/level_valparaiso.tscn"

var level: Node = null

func _ready() -> void:
	print(TEST_NAME, ": starting")
	level = TestUtils.load_main_level(self, TEST_NAME, VALPARAISO_SCENE)
	if level == null:
		return
	call_deferred("_run_test")

func _run_test() -> void:
	await get_tree().process_frame

	var firipu: Node = TestUtils.firipu_node(level, self, TEST_NAME)
	var yuki: Node = level.get_node_or_null("Yuki")
	var kira: Node = level.get_node_or_null("Kira")
	var cometa_a: Node = level.get_node_or_null("CometaCosteraA")
	var cometa_b: Node = level.get_node_or_null("CometaCosteraB")
	var cometa_c: Node = level.get_node_or_null("CometaCosteraC")
	var boss: Node = level.get_node_or_null("PicaflorRobot")
	var medal_area: Node = level.get_node_or_null("MedalArea")

	if firipu == null:
		TestUtils.fail(self, TEST_NAME, "Firipu not found")
		return
	if yuki == null:
		TestUtils.fail(self, TEST_NAME, "Yuki not found")
		return
	if kira == null:
		TestUtils.fail(self, TEST_NAME, "Kira not found")
		return
	if cometa_a == null or cometa_b == null or cometa_c == null:
		TestUtils.fail(self, TEST_NAME, "Cometas costeras not found")
		return
	if boss == null:
		TestUtils.fail(self, TEST_NAME, "PicaflorRobot boss not found")
		return
	if medal_area == null:
		TestUtils.fail(self, TEST_NAME, "MedalArea not found")
		return

	# 1) Verificar que los 4 coleccionables existen
	var expected_collectibles := [
		"ChinitaMatorral",
		"MariposaCostera",
		"LagartijaCerro",
		"CangrejoRoca"
	]
	for node_name in expected_collectibles:
		var collectible: Node = level.get_node_or_null(node_name)
		if collectible == null:
			TestUtils.fail(self, TEST_NAME, "Missing collectible: " + node_name)
			return

	# 2) Probar cometa costera activa kite_glide
	if not firipu.has_method("activate_kite_glide"):
		TestUtils.fail(self, TEST_NAME, "Firipu missing activate_kite_glide")
		return

	cometa_a.call("interact", firipu)
	await get_tree().process_frame

	if not bool(firipu.get("kite_glide_active")):
		TestUtils.fail(self, TEST_NAME, "kite_glide not activated after interacting with cometa")
		return

	# 3) Probar flujo de boss
	if not boss.has_method("expose_core"):
		TestUtils.fail(self, TEST_NAME, "boss missing expose_core")
		return

	boss.set("phase", 3)
	boss.set("_phase_timer", 999.0)
	await get_tree().process_frame

	if yuki.has_method("detect_weakness"):
		yuki.call("detect_weakness", boss)
		await get_tree().process_frame

	if not bool(boss.get("core_exposed")):
		TestUtils.fail(self, TEST_NAME, "core not exposed by Yuki")
		return

	boss.call("hit_by_environment_object", "Piedra")
	await get_tree().process_frame

	if not bool(boss.get("defeated")):
		TestUtils.fail(self, TEST_NAME, "boss not defeated after hitting core")
		return

	# 4) Verificar que el área de medalla se habilita
	await get_tree().process_frame
	if not bool(medal_area.get("monitoring")):
		TestUtils.fail(self, TEST_NAME, "medal area not enabled after boss defeat")
		return

	# 5) Registrar los 4 coleccionables y obtener medalla
	for node_name in expected_collectibles:
		var col: Node = level.get_node_or_null(node_name)
		if col and col.has_method("interact"):
			col.call("interact", firipu)
			await get_tree().process_frame

	if int(firipu.call("get_collected")) != 4:
		TestUtils.fail(self, TEST_NAME, "collected count not 4 after all interactions")
		return

	if firipu.has_method("obtain_medal"):
		firipu.call("obtain_medal")
		await get_tree().process_frame

	if not bool(firipu.get("medal_obtained")):
		TestUtils.fail(self, TEST_NAME, "medal not obtained")
		return

	print(TEST_NAME, ": PASS")
	get_tree().quit(0)