extends Node
class_name AudioManager

# Audio Manager for Firipu Adventure
# Handles all sound effects and music for the game

# Audio buses
const MASTER_BUS := "Master"
const SFX_BUS := "SFX"
const MUSIC_BUS := "Music"
const UI_BUS := "UI"

# Audio streams loaded at runtime from res://audio/sfx/
const SFX_DIR := "res://audio/sfx/"
var _streams: Dictionary = {}
var _player: AudioStreamPlayer = null

# Volume settings (0.0 to 1.0)
var master_volume: float = 0.8
var sfx_volume: float = 0.7
var music_volume: float = 0.5
var ui_volume: float = 0.6

# Sound effect cooldowns to prevent spam
var last_footstep_time: float = 0.0
var footstep_cooldown: float = 0.3

func _ready() -> void:
    _load_streams()
    _setup_audio_buses()
    _apply_volume_settings()
    _player = AudioStreamPlayer.new()
    add_child(_player)
    print("AudioManager initialized")

func _load_streams() -> void:
    for name: String in ["collect", "jump", "land", "footstep", "object_pickup",
            "object_throw", "ui_click", "menu_open", "menu_close",
            "victory", "error", "bike"]:
        var path := SFX_DIR + name + ".wav"
        if ResourceLoader.exists(path):
            _streams[name] = load(path)
        else:
            _streams[name] = null

func _setup_audio_buses() -> void:
    var audio_server := AudioServer

    if audio_server.get_bus_index(MASTER_BUS) == -1:
        audio_server.add_bus(audio_server.bus_count)
        audio_server.set_bus_name(audio_server.bus_count - 1, MASTER_BUS)
    if audio_server.get_bus_index(SFX_BUS) == -1:
        audio_server.add_bus(audio_server.bus_count)
        audio_server.set_bus_name(audio_server.bus_count - 1, SFX_BUS)
        audio_server.set_bus_volume_db(audio_server.get_bus_index(SFX_BUS), linear_to_db(sfx_volume))
    if audio_server.get_bus_index(MUSIC_BUS) == -1:
        audio_server.add_bus(audio_server.bus_count)
        audio_server.set_bus_name(audio_server.bus_count - 1, MUSIC_BUS)
        audio_server.set_bus_volume_db(audio_server.get_bus_index(MUSIC_BUS), linear_to_db(music_volume))
    if audio_server.get_bus_index(UI_BUS) == -1:
        audio_server.add_bus(audio_server.bus_count)
        audio_server.set_bus_name(audio_server.bus_count - 1, UI_BUS)
        audio_server.set_bus_volume_db(audio_server.get_bus_index(UI_BUS), linear_to_db(ui_volume))

    audio_server.set_bus_volume_db(audio_server.get_bus_index(MASTER_BUS), linear_to_db(master_volume))

func _apply_volume_settings() -> void:
    var audio_server := AudioServer
    audio_server.set_bus_volume_db(audio_server.get_bus_index(MASTER_BUS), linear_to_db(master_volume))
    audio_server.set_bus_volume_db(audio_server.get_bus_index(SFX_BUS), linear_to_db(sfx_volume))
    audio_server.set_bus_volume_db(audio_server.get_bus_index(MUSIC_BUS), linear_to_db(music_volume))
    audio_server.set_bus_volume_db(audio_server.get_bus_index(UI_BUS), linear_to_db(ui_volume))

# --- Sound Effect Methods ---

func play_footstep(is_running: bool = false) -> void:
    var time := Time.get_ticks_msec() / 1000.0
    if time - last_footstep_time < footstep_cooldown:
        return
    last_footstep_time = time
    var footstep_pitch: float = 0.8 if is_running else 0.6
    _play_sfx("footstep", 1.0, footstep_pitch, SFX_BUS)

func play_jump() -> void:
    _play_sfx("jump", 0.9, 1.0, SFX_BUS)

func play_land() -> void:
    _play_sfx("land", 0.7, 1.0, SFX_BUS)

func play_collect() -> void:
    _play_sfx("collect", 1.2, 1.0, SFX_BUS)

func collect_with_variation() -> void:
    var pitch := 1.0 + randf() * 0.2
    _play_sfx("collect", pitch, 1.0, SFX_BUS)

func play_object_pickup() -> void:
    _play_sfx("object_pickup", 1.1, 1.0, SFX_BUS)

func play_object_throw() -> void:
    _play_sfx("object_throw", 1.0, 1.0, SFX_BUS)

func play_button_click() -> void:
    _play_sfx("ui_click", 1.0, 1.0, UI_BUS)

func play_menu_open() -> void:
    _play_sfx("menu_open", 0.9, 1.0, UI_BUS)

func play_menu_close() -> void:
    _play_sfx("menu_close", 0.8, 1.0, UI_BUS)

func play_victory() -> void:
    _play_sfx("victory", 1.0, 1.0, MUSIC_BUS)

func play_error() -> void:
    _play_sfx("error", 0.5, 1.0, SFX_BUS)

func play_bike() -> void:
    _play_sfx("bike", 1.0, 1.0, SFX_BUS)

# Public alias used by other scripts (player, HUD)
func play_sfx(sound_type: String, volume: float = 1.0, pitch: float = 1.0, bus: String = SFX_BUS) -> void:
    _play_sfx(sound_type, volume, pitch, bus)

# Reproduce el stream real asociado al tipo de sonido.
# Si no existe el archivo, cae a un tono generado como placeholder.
func _play_sfx(sound_type: String, volume: float = 1.0, pitch: float = 1.0, bus: String = SFX_BUS) -> void:
    var stream: AudioStream = _streams.get(sound_type, null)
    if stream == null:
        stream = _make_placeholder_stream(sound_type)
        if stream == null:
            print("AudioManager: sin stream para %s" % sound_type)
            return
    var player := AudioStreamPlayer.new()
    player.stream = stream
    player.bus = bus
    player.volume_db = linear_to_db(clampf(volume, 0.0, 1.0))
    player.pitch_scale = clampf(pitch, 0.1, 2.0)
    if not is_inside_tree():
        return
    add_child(player)
    player.play()
    player.finished.connect(player.queue_free)

# Genera un tono corto como fallback cuando falta el .wav.
func _make_placeholder_stream(sound_type: String) -> AudioStream:
    var freq := 440.0
    match sound_type:
        "jump":
            freq = 600.0
        "land":
            freq = 220.0
        "footstep":
            freq = 180.0
        "ui_click", "menu_open", "menu_close":
            freq = 880.0
        "victory":
            freq = 660.0
        "error":
            freq = 140.0
        "bike":
            freq = 320.0
        _:
            freq = 520.0
    return _tone_stream(freq, 0.12)

func _tone_stream(freq: float, dur: float) -> AudioStream:
    var samples := _tone_samples(freq, dur)
    var res := AudioStreamWAV.new()
    res.format = AudioStreamWAV.FORMAT_16_BITS
    res.mix_rate = 44100
    res.stereo = false
    var pcm: PackedByteArray = PackedByteArray()
    pcm.resize(samples.size() * 2)
    for i in samples.size():
        var v := int(clampf(samples[i], -1.0, 1.0) * 32767)
        pcm[i * 2] = v & 0xFF
        pcm[i * 2 + 1] = (v >> 8) & 0xFF
    res.data = pcm
    return res

func _tone_samples(freq: float, dur: float) -> PackedFloat32Array:
    var n := int(44100 * dur)
    var out: PackedFloat32Array = PackedFloat32Array()
    out.resize(n)
    for i in n:
        var t := float(i) / float(n)
        var env := 1.0 - t
        out[i] = env * sin(2.0 * PI * freq * float(i) / 44100.0)
    return out

# --- Public API for Volume Control ---

func set_master_volume(volume: float) -> void:
    master_volume = clamp(volume, 0.0, 1.0)
    _apply_volume_settings()

func set_sfx_volume(volume: float) -> void:
    sfx_volume = clamp(volume, 0.0, 1.0)
    _apply_volume_settings()

func set_music_volume(volume: float) -> void:
    music_volume = clamp(volume, 0.0, 1.0)
    _apply_volume_settings()

func set_ui_volume(volume: float) -> void:
    ui_volume = clamp(volume, 0.0, 1.0)
    _apply_volume_settings()

func get_master_volume() -> float:
    return master_volume

func get_sfx_volume() -> float:
    return sfx_volume

func get_music_volume() -> float:
    return music_volume

func get_ui_volume() -> float:
    return ui_volume