extends "res://scripts/enemies/boss_base.gd"
class_name BossCaracolBlindadoLluvias

# Caracol Blindado Espacial de la Lluvia - Los Ríos
# Fase 1: Arrastre blindado con estela de baba
# Fase 2: Caparazón giratorio (reflecta proyectiles)
# Fase 3: Proyectiles de baba ácida
# Fase 4: Núcleo en la cabeza

@export var slime_trail_duration: float = 8.0
@export var spin_duration: float = 5.0

var _spin_timer: float = 0.0
var _is_spinning: bool = false

func _ready() -> void:
	super._ready()
	phase_duration = 6.0
	vulnerable_duration = 4.0
	patrol_speed = 1.5
	alert_speed = 3.0
	print("CARACOL LLUVIAS: La humedad protege mi caparazón")

func _on_phase_1(delta: float) -> void:
	# Arrastre lento con estela de baba
	if target and _phase_timer <= 0.0:
		_phase_timer = 3.0
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * 2.5
		velocity.z = dir.z * 2.5
		print("CARACOL LLUVIAS: Arrastre viscoso!")
	else:
		_phase_timer -= delta

func _on_phase_2(delta: float) -> void:
	# Caparazón giratorio - refleja proyectiles
	if not _is_spinning:
		_is_spinning = true
		_spin_timer = spin_duration
		print("CARACOL LLUVIAS: Caparazón giratorio!")
	
	if _is_spinning:
		_spin_timer -= delta
		rotation.y += delta * 8.0  # Giro rápido
		# Reflejar proyectiles en área
		if _spin_timer <= 0.0:
			_is_spinning = false
			_phase_timer = 0.0
	else:
		_phase_timer -= delta

func _on_phase_3(delta: float) -> void:
	# Proyectiles de baba ácida
	if target and _phase_timer <= 0.0:
		_phase_timer = 3.0
		print("CARACOL LLUVIAS: Baba ácida!")
		# Spawn proyectiles de baba (instanciar scene)
	else:
		_phase_timer -= delta

func _on_vulnerable(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, delta * 5)
	velocity.z = move_toward(velocity.z, 0, delta * 5)