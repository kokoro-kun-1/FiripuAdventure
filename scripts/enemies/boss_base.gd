extends "res://scripts/enemies/robot_enemy.gd"
class_name BossBase

# Clase base para todos los bosses regionales
# Extiende RobotEnemy y añade sistema de fases + núcleo expuesto

signal boss_phase_changed(phase: int)
signal boss_defeated

enum Phase { PHASE_1 = 1, PHASE_2 = 2, PHASE_3 = 3, VULNERABLE = 4 }

@export var phase_duration: float = 5.0
@export var vulnerable_duration: float = 3.0

var phase: int = 1
var core_exposed: bool = false
var defeated: bool = false
var _phase_timer: float = 0.0
var _vulnerable_timer: float = 0.0

# Override en subclases para comportamiento específico por fase
func _on_phase_1(delta: float) -> void:
	pass

func _on_phase_2(delta: float) -> void:
	pass

func _on_phase_3(delta: float) -> void:
	pass

func _on_vulnerable(delta: float) -> void:
	pass

func _ready() -> void:
	super._ready()
	state = State.ALERTED
	_set_phase(1)
	print("%s: jefe inicializado en fase 1" % get_class())

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if defeated:
		return
	
	match phase:
		1:
			_on_phase_1(delta)
			_phase_timer += delta
			if _phase_timer >= phase_duration:
				_set_phase(2)
		2:
			_on_phase_2(delta)
			_phase_timer += delta
			if _phase_timer >= phase_duration:
				_set_phase(3)
		3:
			_on_phase_3(delta)
			_phase_timer += delta
			if _phase_timer >= phase_duration:
				_set_phase(4)  # Vulnerable
		4:  # VULNERABLE
			_on_vulnerable(delta)
			_vulnerable_timer += delta
			if _vulnerable_timer >= vulnerable_duration:
				_set_phase(1)  # Reinicia ciclo

func _set_phase(next_phase: int) -> void:
	phase = next_phase
	_phase_timer = 0.0
	_vulnerable_timer = 0.0
	core_exposed = (phase == 4)
	boss_phase_changed.emit(phase)
	print("%s: fase %d" % [get_class(), phase])

# Yuki llama esto cuando detecta el punto débil
func expose_core() -> void:
	if phase == 4 and not defeated:
		core_exposed = true
		print("%s: núcleo expuesto por Yuki" % get_class())

# Firipu golpea el núcleo con objeto del entorno
func hit_by_environment_object(label: String) -> void:
	if defeated:
		return
	if phase == 4 and core_exposed:
		_defeat()
		return
	super.hit_by_environment_object(label)

func _defeat() -> void:
	defeated = true
	core_exposed = false
	state = State.DISABLED
	velocity = Vector3.ZERO
	boss_defeated.emit()
	print("%s: derrotado" % get_class())

# Método para tests: forzar fase vulnerable inmediatamente
func force_vulnerable() -> void:
	phase = 4
	_phase_timer = 0.0
	_vulnerable_timer = 0.0
	core_exposed = true
	boss_phase_changed.emit(phase)
	print("%s: fase vulnerable forzada" % get_class())

# Para que Yuki detecte - override en subclases si necesita distancia distinta
func _process(delta: float) -> void:
	pass