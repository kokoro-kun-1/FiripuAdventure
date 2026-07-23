extends Node

const TestUtils = preload("res://tests/test_utils.gd")
const TEST_NAME := "BIOBIO_STRUCTURE_TEST"

func _ready() -> void:
	print(TEST_NAME, ": starting")
	var level := TestUtils.load_main_level(self, TEST_NAME)
	if level == null:
		return
	call_deferred("_run_test", level)

func _run_test(level: Node) -> void:
	await get_tree().process_frame
	var player := level.get_node_or_null("Firipu")
	if player == null or not player.has_method("set_nearby_interactable") or not player.has_method("clear_nearby_interactable"):
		TestUtils.fail(self, TEST_NAME, "player proximity interaction API is missing")
		return
	if not level.has_method("get_route_metrics"):
		TestUtils.fail(self, TEST_NAME, "expanded route metrics API is missing")
		return
	var metrics: Dictionary = level.call("get_route_metrics")
	if int(metrics.get("segments", 0)) != 5:
		TestUtils.fail(self, TEST_NAME, "Biobío must have five structured segments")
		return
	if float(metrics.get("route_length_m", 0.0)) < 400.0:
		TestUtils.fail(self, TEST_NAME, "route is shorter than 400 meters")
		return
	var optimal_seconds := float(metrics.get("optimal_seconds", 0.0))
	if optimal_seconds < 210.0 or optimal_seconds > 270.0:
		TestUtils.fail(self, TEST_NAME, "optimal route must target four minutes, got %.1f" % optimal_seconds)
		return
	var gates := level.get_node_or_null("ProgressGates")
	var checkpoints := level.get_node_or_null("Checkpoints")
	if gates == null or gates.get_child_count() != 4:
		TestUtils.fail(self, TEST_NAME, "expected four progress gates")
		return
	if checkpoints == null or checkpoints.get_child_count() != 5:
		TestUtils.fail(self, TEST_NAME, "expected five segment checkpoints")
		return

	# El gate 4 (índice 3) debe bloquearse hasta que el Diario esté completo
	# Y el jefe (BossCosmicBeetle) esté derrotado. Antes del fix comprobaba
	# robot.get("state")==3, que el robot básico nunca alcanza -> gate nunca se abría.
	var gate4 := gates.get_child(3) as StaticBody3D
	var boss := level.get_node_or_null("BossCosmicBeetle")
	if gate4 == null or boss == null:
		TestUtils.fail(self, TEST_NAME, "gate 4 or boss node missing")
		return
	if not gate4.has_method("get_child"):
		TestUtils.fail(self, TEST_NAME, "gate 4 has no children")
		return
	var gate4_collision := gate4.get_child(0) as CollisionShape3D
	if gate4_collision == null:
		TestUtils.fail(self, TEST_NAME, "gate 4 collision missing")
		return
	# Estado inicial: con 0 coleccionables y jefe vivo, el gate debe estar cerrado.
	level.call_deferred("_update_progress_gates")
	await get_tree().process_frame
	if gate4_collision.disabled:
		TestUtils.fail(self, TEST_NAME, "gate 4 must stay closed with diary incomplete and boss alive")
		return
	# Simula Diario completo + jefe vivo: sigue cerrado.
	var firipu := level.get_node_or_null("Firipu")
	if firipu != null and firipu.has_method("set_collected"):
		firipu.set_collected(4)
	level.call_deferred("_update_progress_gates")
	await get_tree().process_frame
	if gate4_collision.disabled:
		TestUtils.fail(self, TEST_NAME, "gate 4 must stay closed even with full diary if boss alive")
		return
	# Derrota el jefe: ahora sí debe abrirse.
	boss.set("defeated", true)
	level.call_deferred("_update_progress_gates")
	await get_tree().process_frame
	if not gate4_collision.disabled:
		TestUtils.fail(self, TEST_NAME, "gate 4 must open when diary complete and boss defeated")
		return

	print(TEST_NAME, ": PASS")
	get_tree().quit(0)