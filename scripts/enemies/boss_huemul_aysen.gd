extends "res://scripts/enemies/boss_base.gd"
class_name BossHuemulAysen

# Huemul Robot Glacial de Aysén - Aysén
# Fase 1: Cargada glacial con patadas de hielo
# Fase 2: Ventisca cegadora
# Fase 3: Estalactitas de hielo cayendo
# Fase 4: Núcleo en el pecho

@export var charge_speed: float = 12.0
@export var ice_spike_interval: float = 1.5

var _spike_timer: float = 0.0

func _ready() -> void:
	super._ready()
	phase_duration = 5.0
	vulnerable_duration = 3.5
	patrol_speed = 2.5
	alert_speed = 12.0
	print("HUEMUL AYSÉN: El glaciar te observa")

func _on_phase_1(delta: float) -> void:
	# Cargada glacial
	if target and _phase_timer <= 0.0:
		_phase_timer = 2.5
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * charge_speed
		velocity.z = dir.z * charge_speed
		print("HUEMUL AYSÉN: Carga glacial!")
	else:
		_phase_timer -= delta

func _on_phase_2(delta: float) -> void:
	# Ventisca cegadora - ralentiza y desorienta
	if target:
		var dist = global_position.distance_to(target.global_position)
		if dist < 15.0:
			# Ralentizar a Firipu en área
			target.call_deferred("apply_slow", 0.5, 2.0)
	_phase_timer -= delta

func _on_phase_3(delta: float) -> void:
	# Estalactitas de hielo cayendo
	_spike_timer -= delta
	if _spike_timer <= 0.0:
		_spike_timer = ice_spike_interval
		# Spawn estalactitas en área (instanciar scene)
		print("HUEMUL AYSÉN: Estalactitas de hielo!")
	else:
		_spike_timer -= delta

func _on_vulnerable(delta: float) -> void:
	# Pecho expuesto
	velocity.x = move_toward(velocity.x, 0, delta * 10)
	velocity.z = move_toward(velocity.z, 0, delta * 10)