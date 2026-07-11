extends Node

const TestUtils = preload("res://tests/test_utils.gd")
const TEST_NAME: String = "BIKE_TEST"

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
	var bike: Node = level.get_node_or_null("Bike")
	if bike == null:
		TestUtils.fail(self, TEST_NAME, "Bike node not found")
		return
	if firipu == null or not firipu.has_method("mount_bike"):
		TestUtils.fail(self, TEST_NAME, "firipu no tiene mount_bike")
		return

	# baseline
	var base_run = float(firipu.get("run_speed"))
	bike.call("interact", firipu)
	await get_tree().process_frame

	if not bool(firipu.get("bike_boost_active")):
		TestUtils.fail(self, TEST_NAME, "boost no activo tras interact")
		return
	if bike.visible:
		TestUtils.fail(self, TEST_NAME, "bike no se oculto")
		return

	# verify multiplier applied
	var boosted_run = float(firipu.get("run_speed")) * float(firipu.get("bike_multiplier"))
	if not is_equal_approx(boosted_run, base_run * 1.8):
		TestUtils.fail(self, TEST_NAME, "multiplicador de velocidad incorrecto")
		return

	# expiry
	firipu.call("dismount_bike")
	firipu.call("mount_bike", 0.2)
	await get_tree().create_timer(0.4).timeout
	await get_tree().process_frame
	if bool(firipu.get("bike_boost_active")):
		TestUtils.fail(self, TEST_NAME, "boost no expiro")
		return

	print(TEST_NAME, ": PASS")
	get_tree().quit(0)
