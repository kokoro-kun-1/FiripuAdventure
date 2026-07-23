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
	print(TEST_NAME, ": PASS")
	get_tree().quit(0)
