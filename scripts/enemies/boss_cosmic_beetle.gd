extends "res://scripts/enemies/robot_enemy.gd"
class_name BossCosmicBeetle

signal boss_phase_changed(phase: int)
signal boss_defeated

enum Phase { CHARGE = 1, SPARKS = 2, CORE = 3 }

@export var phase_duration := 4.0

var phase: int = Phase.CHARGE
var core_exposed := false
var defeated := false
var _phase_timer := 0.0

func _ready() -> void:
    super._ready()
    # El jefe embiste mas rapido que un enemigo comun.
    patrol_speed = 3.2
    alert_speed = 5.5
    state = State.ALERTED
    _phase_timer = 0.0
    _set_phase(Phase.CHARGE)

func _physics_process(delta: float) -> void:
    super._physics_process(delta)
    if defeated:
        return
    _phase_timer += delta
    match phase:
        Phase.CHARGE:
            if _phase_timer >= phase_duration:
                _set_phase(Phase.SPARKS)
        Phase.SPARKS:
            if _phase_timer >= phase_duration:
                _set_phase(Phase.CORE)
        Phase.CORE:
            pass

func _set_phase(next: int) -> void:
    phase = next
    _phase_timer = 0.0
    boss_phase_changed.emit(phase)
    print("JEFE: fase ", phase)

# Yuki detecta el punto debil en la fase de nucleo.
func expose_core() -> void:
    if phase == Phase.CORE and not defeated:
        core_exposed = true
        print("JEFE: nucleo expuesto")

# Firipu desactiva el nucleo con una piedra/rama.
func hit_by_environment_object(label: String) -> void:
    if defeated:
        return
    if phase == Phase.CORE and core_exposed:
        _defeat()
        return
    super.hit_by_environment_object(label)

func _defeat() -> void:
    defeated = true
    core_exposed = false
    state = State.DISABLED
    velocity = Vector3.ZERO
    boss_defeated.emit()
    print("JEFE: derrotado — Biobio liberado")
