extends Node

const TestUtils = preload("res://tests/test_utils.gd")
const TEST_NAME: String = "ARICA_TEST"
const ARICA_SCENE := "res://scenes/levels/level_arica_parinacota.tscn"

var level: Node = null

func _ready() -> void:
	print(TEST_NAME, ": starting")
	level = TestUtils.load_main_level(self, TEST_NAME, ARICA_SCENE)
	if level == null:
		return
	call_deferred("_run_test")

func _run_test() -> void:
	await get_tree().process_frame

	var firipu: Node = TestUtils.firipu_node(level, self, TEST_NAME)
	var yuki: Node = level.get_node_or_null("Yuki")
	var kira: Node = level.get_node_or_null("Kira")
	var viento_a: Node = level.get_node_or_null("SaltoVientoAltiplanicoA")
	var viento_b: Node = level.get_node_or_null("SaltoVientoAltiplanicoB")
	var viento_c: Node = level.get_node_or_null("SaltoVientoAltiplanicoC")
	var viento_d: Node = level.get_node_or_null("SaltoVientoAltiplanicoD")
	var boss: Node = level.get_node_or_null("PicaflorCosmico")
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
	if viento_a == null or viento_b == null or viento_c == null or viento_d == null:
		TestUtils.fail(self, TEST_NAME, "Saltos viento altiplánico not found")
		return
	if boss == null:
		TestUtils.fail(self, TEST_NAME, "PicaflorCosmico boss not found")
		return
	if medal_area == null:
		TestUtils.fail(self, TEST_NAME, "MedalArea not found")
		return

	# 1) Verificar que los 4 coleccionables existen
	var expected_collectibles := [
		"PicaflorArica",
		"LagartijaAltiplano",
		"EscarabajoDesierto",
		"LibelulaBofedal"
	]
	for node_name in expected_collectibles:
		var collectible: Node = level.get_node_or_null(node_name)
		if collectible == null:
			TestUtils.fail(self, TEST_NAME, "Missing collectible: " + node_name)
			return

	# 2) Probar salto viento altiplánico activa altiplano_wind
	if not firipu.has_method("activate_altiplano_wind"):
		TestUtils.fail(self, TEST_NAME, "Firipu missing activate_altiplano_wind")
		return

	viento_a.call("interact", firipu)
	await get_tree().process_frame

	if not bool(firipu.get("altiplano_wind_active")):
		TestUtils.fail(self, TEST_NAME, "altiplano_wind not activated after interacting")
		return

	# 3) Probar flujo de boss
	if not boss.has_method("expose_core"):
		TestUtils.fail(self, TEST_NAME, "boss missing expose_core")
		return

	boss.call("force_vulnerable")

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

	# 6) Verificar que los labels de los coleccionables coincidan con regiones.json.
	var expected_labels := _arica_collectible_labels()
	if expected_labels.is_empty():
		TestUtils.fail(self, TEST_NAME, "no se pudieron leer especies de regiones.json")
		return
	var actual_labels: Array[String] = []
	for c in TestUtils.collectible_nodes(get_tree()):
		actual_labels.append(String(c.get("label")))
	if actual_labels.size() != expected_labels.size():
		TestUtils.fail(self, TEST_NAME, "conteo de especies distinto al JSON")
		return
	for e in expected_labels:
		if not actual_labels.has(e):
			TestUtils.fail(self, TEST_NAME, "especie faltante o mal etiquetada: %s (escena: %s)" % [e, str(actual_labels)])
			return

	print(TEST_NAME, ": PASS")
	get_tree().quit(0)

func _arica_collectible_labels() -> Array[String]:
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
		if String(region.get("id", "")) == "arica_parinacota":
			for sp in region.get("collectibles", []):
				result.append(String(sp))
			break
	return result