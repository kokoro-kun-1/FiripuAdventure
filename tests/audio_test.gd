extends Node

const TestUtils = preload("res://tests/test_utils.gd")
const TEST_NAME: String = "AUDIO_TEST"

func _ready() -> void:
    print(TEST_NAME, ": starting")
    await get_tree().process_frame
    var audio: Node = get_node_or_null("/root/AudioManager")
    if audio == null:
        TestUtils.fail(self, TEST_NAME, "AudioManager autoload no encontrado")
        return
    if not audio.has_method("play_sfx"):
        TestUtils.fail(self, TEST_NAME, "AudioManager sin play_sfx")
        return

    # Reproducir no debe lanzar error y debe crear un reproductor con stream.
    audio.call("play_sfx", "collect", 1.0, 1.0)
    audio.call("play_collect")
    audio.call("play_victory")
    await get_tree().process_frame

    # Debe existir al menos un AudioStreamPlayer hijo reproduciendo.
    var playing := 0
    for c in audio.get_children():
        if c is AudioStreamPlayer and c.stream != null:
            playing += 1
    if playing == 0:
        TestUtils.fail(self, TEST_NAME, "ningun reproductor de audio activo tras play")
        return

    print(TEST_NAME, ": PASS")
    get_tree().quit(0)
