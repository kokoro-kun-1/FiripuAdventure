extends Node
class_name AudioManager

# Audio Manager for Firipu Adventure
# Handles all sound effects and music for the game

# Audio buses
const MASTER_BUS := "Master"
const SFX_BUS := "SFX"
const MUSIC_BUS := "Music"
const UI_BUS := "UI"

# Audio streams (will be loaded when available)
# For now, we'll use placeholders or generate simple tones
# In a real implementation, these would be AudioStream variables pointing to imported audio files

# Volume settings (0.0 to 1.0)
var master_volume: float = 0.8
var sfx_volume: float = 0.7
var music_volume: float = 0.5
var ui_volume: float = 0.6

# Sound effect cooldowns to prevent spam
var last_footstep_time: float = 0.0
var footstep_cooldown: float = 0.3

func _ready() -> void:
    _setup_audio_buses()
    _apply_volume_settings()
    print("AudioManager initialized")

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
    var footstep_pitch: float = 0.6
    if is_running:
        footstep_pitch = 0.8
    _play_sfx_placeholder("footstep", footstep_pitch, SFX_BUS)

func play_jump() -> void:
    _play_sfx_placeholder("jump", 0.9, SFX_BUS)

func play_land() -> void:
    _play_sfx_placeholder("land", 0.7, SFX_BUS)

func play_collect() -> void:
    _play_sfx_placeholder("collect", 1.2, SFX_BUS)

func collect_with_variation() -> void:
    var pitch := 1.0 + randf() * 0.2
    _play_sfx_placeholder("collect", pitch, SFX_BUS)

func play_object_pickup() -> void:
    _play_sfx_placeholder("object_pickup", 1.1, SFX_BUS)

func play_object_throw() -> void:
    _play_sfx_placeholder("object_throw", 1.0, SFX_BUS)

func play_button_click() -> void:
    _play_sfx_placeholder("ui_click", 1.0, UI_BUS)

func play_menu_open() -> void:
    _play_sfx_placeholder("menu_open", 0.9, UI_BUS)

func play_menu_close() -> void:
    _play_sfx_placeholder("menu_close", 0.8, UI_BUS)

func play_victory() -> void:
    _play_sfx_placeholder("victory", 1.0, MUSIC_BUS)

func play_error() -> void:
    _play_sfx_placeholder("error", 0.5, SFX_BUS)

# Public alias used by other scripts (player, HUD)
func play_sfx(sound_type: String, volume: float = 1.0, pitch: float = 1.0, bus: String = SFX_BUS) -> void:
    _play_sfx_placeholder(sound_type, pitch, bus)

# --- Helper Methods ---

func _play_sfx_placeholder(sound_type: String, pitch: float = 1.0, bus: String = SFX_BUS) -> void:
    print("AudioManager: Would play %s sound (pitch: %.2f) on %s bus" % [sound_type, pitch, bus])

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
