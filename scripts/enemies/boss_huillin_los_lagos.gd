extends "res://scripts/enemies/boss_base.gd"
class_name BossHuillinLosLagos

# Huillín Robot de los Lagos - Los Lagos
# Fase 1: Nado ágil entre islas
# Fase 2: Corrientes de agua atrapantes
# Fase 3: Burbujas sónicas
# Fase 4: Núcleo en el vientre

@export var swim_speed: float = 9.0
@export var current_duration: float = 5.0

var _current_timer: float = 0.0
var _has_current: bool = false

func _ready() -> void:
	super._ready()
	phase_duration = 6.0
	vulnerable_duration = 4.0
	patrol_speed = 3.5
	alert_speed = 9.0
	print("HUILLÍN LAGOS: Las aguas me pertenecen")

func _on_phase_1(delta: float) -> void:
	# Nado ágil entre islas
	if target and _phase_timer <= 0.0:
		_phase_timer = 4.0
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * swim_speed
		velocity.z = dir.z * swim_speed
		print("HUILLÍN LAGOS: Nado entre islas!")
	else:
		_phase_timer -= delta

func _on_phase_2(delta: float) -> void:
	# Corrientes de agua atrapantes
	if not _has_current:
		_has_current = true
		_current_timer = current_duration
		print("HUILLÍN LAGOS: Corriente atrapante!")
	
	if _has_current:
		_current_timer -= delta
		if target:
			# Atraer hacia el centro de la corriente
			var dir = (global_position - target.global_position).normalized()
			dir.y = 0
			target.call_deferred("apply_force", dir * 3.0)
		if _current_timer <= 0.0:
			_has_current = false
			_phase_timer = 0.0
	else:
		_phase_timer -= delta

func _on_phase_3(delta: float) -> void:
	# Burbujas sónicas - aturden
	if target and _phase_timer <= 0.0:
		_phase_timer = 3.0
		print("HUILLÍN LAGOS: Burbujas sónicas!")
		if target:
			target.call_deferred("apply_stun", 1.5)
	else:
		_phase_timer -= delta

func _on_vulnerable(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, delta * 10)
	velocity.z = move_toward(velocity.z, 0, delta * 10)