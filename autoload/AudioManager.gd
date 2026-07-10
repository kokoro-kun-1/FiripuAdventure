extends Node

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
var footstep_cooldown: float = 0.3  # seconds between footsteps

func _ready() -> void:
    # Setup audio buses if they don't exist
    _setup_audio_buses()
    # Apply initial volume settings
    _apply_volume_settings()
    print("AudioManager initialized")

func _setup_audio_buses() -> void:
    # Create custom audio buses for better sound mixing
    var audio_server := AudioServer
    
    # Check if buses already exist
    if not audio_server.has_bus(MASTER_BUS):
        audio_server.add_bus(MASTER_BUS)
    if not audio_server.has_bus(SFX_BUS):
        audio_server.add_bus(SFX_BUS)
        audio_server.set_bus_volume_db(SFX_BUS, linear_to_db(sfx_volume))
    if not audio_server.has_bus(MUSIC_BUS):
        audio_server.add_bus(MUSIC_BUS)
        audio_server.set_bus_volume_db(MUSIC_BUS, linear_to_db(music_volume))
    if not audio_server.has_bus(UI_BUS):
        audio_server.add_bus(UI_BUS)
        audio_server.set_bus_volume_db(UI_BUS, linear_to_db(ui_volume))
    
    # Set master bus volume
    audio_server.set_bus_volume_db(MASTER_BUS))

# Apply volume settings
func _apply_volume_settings() -> void:
    var audio_server := AudioServer
    audio_server.set_bus_volume_db(MASTER_BUS, linear_to_db(master_volume))
    audio_server.set_bus_volume_db(SFX_BUS, linear_to_db(sfx_volume))
    audio_server.set_bus_volume_db(MUSIC_BUS, linear_to_db(music_volume))
    audio_server.set_bus_volume_db(UI_BUS, linear_to_db(ui_volume))

# --- Sound Effect Methods ---

func play_footstep(is_running: boolean = false) -> void:
    """Play footstep sound with variation based on movement speed"""
    var time := Time.get_ticks_msec() / 1000.0
    if time - last_footstep_time < footstep_cooldown:
        return
    
    last_footstep_time = time
    
    # In a real implementation, we'd play different sounds for different surfaces
    # and variations to avoid repetition
    # For now, we'll emit a signal or use a simple beep as placeholder
    _play_sfx_placeholder("footstep", pitch=0.8 if is_running else 0.6)

func play_jump() -> void:
    """Play jump sound"""
    _play_sfx_placeholder("jump", pitch=0.9)

func play_land() -> void:
    """Play landing sound"""
    _play_sfx_placeholder("land", pitch=0.7)

func play_collect() -> void:
    """Play sound when collecting an item (fauna, object, medal)"""
    _play_sfx_placeholder("collect", pitch=1.2)

func collect_with_variation() -> void:
    """Play collect sound with slight pitch variation for more natural feel"""
    var pitch := 1.0 + randf() * 0.2  # 1.0 to 1.2
    _play_sfx_placeholder("collect", pitch=pitch)

func play_object_pickup() -> void:
    """Play sound when picking up an object (stick/stone)"""
    _play_sfx_placeholder("object_pickup", pitch=1.1)

func play_object_throw() -> void:
    """Play sound when throwing/using an object"""
    _play_sfx_placeholder("object_throw", pitch=1.0)

func play_button_click() -> void:
    """Play UI button click sound"""
    _play_sfx_placeholder("ui_click", bus=UI_BUS, pitch=1.0)

func play_menu_open() -> void:
    """Play sound when opening a menu (pause, inventory, etc.)"""
    _play_sfx_placeholder("menu_open", bus=UI_BUS, pitch=0.9)

func play_menu_close() -> void:
    """Play sound when closing a menu"""
    _play_sfx_placeholder("menu_close", bus=UI_BUS, pitch=0.8)

func play_victory() -> void:
    """Play victory jingle or sound"""
    _play_sfx_placeholder("victory", bus=MUSIC_BUS, pitch=1.0)

func play_error() -> void:
    """Play error/negative feedback sound"""
    _play_sfx_placeholder("error", bus=SFX_BUS, pitch=0.5)

# --- Helper Methods ---

func _play_sfx_placeholder(sound_type: String, pitch: float = 1.0, bus: String = SFX_BUS) -> void:
    """Placeholder for sound effects - in real implementation would play actual audio"""
    # For now, just print what would be played
    # In a real game, this would use AudioStreamPlayer to play actual sounds
    print("AudioManager: Would play %s sound (pitch: %.2f) on %s bus" % [sound_type, pitch, bus])
    
    # TODO: Replace with actual audio playback when audio files are added
    # Example implementation:
    # var player := AudioStreamPlayer3D.new() if is_3d else AudioStreamPlayer.new()
    # player.stream = preload("res://audio/sfx/%s.ogg" % sound_type)
    # player.pitch_scale = pitch
    # audio_server.get_bus_index(bus) -> player.connect("finished", player, "queue_free")
    # add_child(player)
    # player.play()

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