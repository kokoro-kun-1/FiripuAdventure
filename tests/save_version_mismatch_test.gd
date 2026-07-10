extends Node

const TestUtils = preload("res://tests/test_utils.gd")
const TEST_NAME: String = "VERSION_TEST"

var level: Node = null

func _ready() -> void:
    print(TEST_NAME, ": starting")
    level = TestUtils.load_main_level(self, TEST_NAME)
    if level == null:
        return
    call_deferred("_run_test")

func _run_test() -> void:
    await get_tree().process_frame

    var sg: Node = TestUtils.save_game_node(self, TEST_NAME)
    var firipu: Node = TestUtils.firipu_node(level, self, TEST_NAME)
    if sg == null or firipu == null:
        return

    firipu.call("set_collected", 2)
    var before_load: int = int(firipu.call("get_collected"))
    print(TEST_NAME, ": before_load_collected=", before_load)

    var bad_save := {
        "version": 999,
        "player_position": [123.0, 456.0, 789.0],
        "player_rotation_y": 1.5,
        "collected_count": 0,
        "collected_names": [],
        "medal_obtained": false,
        "world_completed": false
    }

    var file := FileAccess.open(TestUtils.SAVE_PATH, FileAccess.WRITE)
    if file == null:
        TestUtils.fail(self, TEST_NAME, "could not write bad save file")
        return
    file.store_string(JSON.stringify(bad_save))
    file.close()
    print(TEST_NAME, ": wrote bad save version=999")

    sg.call("load_game", level)

    var after_load: int = int(firipu.call("get_collected"))
    print(TEST_NAME, ": after_load_collected=", after_load)

    if after_load != before_load:
        TestUtils.fail(self, TEST_NAME, "load_game applied incompatible save, expected rejection")
        return

    print(TEST_NAME, ": PASS")
    get_tree().quit(0)
