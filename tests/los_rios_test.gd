extends Node

const TestUtils = preload("res://tests/test_utils.gd")
const TEST_NAME: String = "LOS_RIOS_TEST"
const LOS_RIOS_SCENE := "res://scenes/levels/level_los_rios.tscn"

var level: Node = null

func _ready() -> void:
	print(TEST_NAME, ": starting")
	level = TestUtils.load_main_level(self, TEST_NAME, LOS_RIOS_SCENE)
	if level == null:
		return
	call_deferred("_run_test")

func _run_test() -> void:
	await get_tree().process_frame

	var firipu: Node = TestUtils.firipu_node(level, self, TEST_NAME)
	var yuki: Node = level.get_node_or_null("Yuki")
	var kira: Node = level.get_node_or_null("Kira")
	var hoja_a: Node = level.get_node_or_null("HojaParaguasA")
	var hoja_b: Node = level.get_node_or_null("HojaParaguasB")
	var hoja_c: Node = level.get_node_or_null("HojaParaguasC")
	var boss: Node = level.get_node_or_null("CaracolBlindado")
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
	if hoja_a == null or hoja_b == null or hoja_c == null:
		TestUtils.fail(self, TEST_NAME, "Hojas paraguas not found")
		return
	if boss == null:
		TestUtils.fail(self, TEST_NAME, "CaracolBlindado boss not found")
		return
	if medal_area == null:
		TestUtils.fail(self, TEST_NAME, "MedalArea not found")
		return

	# 1) Verificar que los 4 coleccionables existen
	var expected_collectibles := [
		"CaracolBosque",
		"LibelulaRio",
		"RanitaDarwin",
		"EscarabajoMusgo"
	]
	for node_name in expected_collectibles:
		var collectible: Node = level.get_node_or_null(node_name)
		if collectible == null:
			TestUtils.fail(self, TEST_NAME, "Missing collectible: " + node_name)
			return

	# 2) Probar hoja paraguas activa glide_boost
	if not firipu.has_method("activate_glide_boost"):
		TestUtils.fail(self, TEST_NAME, "Firipu missing activate_glide_boost")
		return

	# Interactuar con la primera hoja
	hoja_a.call("interact", firipu)
	await get_tree().process_frame

	if not bool(firipu.get("glide_boost_active")):
		TestUtils.fail(self, TEST_NAME, "glide_boost not activated after interacting with hoja")
		return

	# 3) Probar flujo de boss (similar a boss_test)
	if not boss.has_method("expose_core"):
		TestUtils.fail(self, TEST_NAME, "boss missing expose_core")
		return

	# Forzar fase de núcleo
	boss.set("phase", 3)
	boss.set("_phase_timer", 999.0)
	await get_tree().process_frame

	# Yuki detecta punto débil
	if yuki.has_method("detect_weakness"):
		yuki.call("detect_weakness", boss)
		await get_tree().process_frame

	if not bool(boss.get("core_exposed")):
		TestUtils.fail(self, TEST_NAME, "core not exposed by Yuki")
		return

	# Golpear núcleo con piedra
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

	# Obtener medalla
	if firipu.has_method("obtain_medal"):
		firipu.call("obtain_medal")
		await get_tree().process_frame

	if not bool(firipu.get("medal_obtained")):
		TestUtils.fail(self, TEST_NAME, "medal not obtained")
		return

	print(TEST_NAME, ": PASS")
	get_tree().quit(0)