extends "res://scripts/enemies/boss_base.gd"
class_name BossTricahueOhiggins

# Tricahue Robot de las Quebradas - O'Higgins
# Fase 1: Vuelo en quebradas
# Fase 2: Eco direccional (empuja a Firipu)
# Fase 3: Picotazo en picado sincronizado
# Fase 4: Núcleo en las alas

@export var echo_push_force: float = 8.0

var _echo_timer: float = 0.0

func _ready() -> void:
	super._ready()
	phase_duration = 5.0
	vulnerable_duration = 4.0
	alert_speed = 5.0
	print("TRICAHUE QUEBRADAS: Mi eco marca el camino")

func _on_phase_1(delta: float) -> void:
	# Vuelo ágil entre quebradas
	if target and _phase_timer <= 0.0:
		_phase_timer = 3.0
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * 8.0
		velocity.z = dir.z * 8.0
		print("TRICAHUE QUEBRADAS: Vuelo de quebrada!")
	else:
		_phase_timer -= delta

func _on_phase_2(delta: float) -> void:
	# Eco direccional - empuja a Firipu
	if _echo_timer <= 0.0 and target:
		_echo_timer = 2.5
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		target.call_deferred("apply_force", dir * echo_push_force)
		print("TRICAHUE QUEBRADAS: ¡Eco direccional!")
	else:
		_echo_timer -= delta

func _on_phase_3(delta: float) -> void:
	# Picotazo sincronizado en picado
	if _phase_timer <= 0.0 and target:
		_phase_timer = 2.0
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * 16.0
		velocity.z = dir.z * 16.0
		print("TRICAHUE QUEBRADAS: Picotazo certero!")
	else:
		_phase_timer -= delta

func _on_vulnerable(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, delta * 10)
	velocity.z = move_toward(velocity.z, 0, delta * 10)