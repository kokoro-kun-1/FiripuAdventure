extends "res://scripts/enemies/boss_base.gd"
class_name BossPicaflorValparaiso

# Picaflor Robot de los Acantilados - Valparaíso
# Fase 1: Vuelo vertical entre acantilados
# Fase 2: Picotazo sónico
# Fase 3: Polen metálico (área de confusión)
# Fase 4: Núcleo en el pico

@export var vertical_speed: float = 10.0
@export var pollen_interval: float = 4.0

var _pollen_timer: float = 0.0

func _ready() -> void:
	super._ready()
	phase_duration = 5.0
	vulnerable_duration = 4.0
	alert_speed = 6.0
	print("PICAFLOR ACANTILADOS: El viento te lleva... o te derriba")

func _on_phase_1(delta: float) -> void:
	# Vuelo vertical entre acantilados
	if target and _phase_timer <= 0.0:
		_phase_timer = 3.0
		velocity.y = vertical_speed
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * 6.0
		velocity.z = dir.z * 6.0
		print("PICAFLOR ACANTILADOS: Ascenso vertical!")
	else:
		_phase_timer -= delta

func _on_phase_2(delta: float) -> void:
	# Picotazo sónico en picado
	if target and _phase_timer <= 0.0:
		_phase_timer = 2.0
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * 18.0
		velocity.z = dir.z * 18.0
		print("PICAFLOR ACANTILADOS: ¡Picotazo sónico!")
	else:
		_phase_timer -= delta

func _on_phase_3(delta: float) -> void:
	# Polen metálico - área de confusión
	_pollen_timer -= delta
	if _pollen_timer <= 0.0:
		_pollen_timer = 4.0
		print("PICAFLOR ACANTILADOS: Polen metálico!")
		if target:
			target.call_deferred("apply_confusion", 3.0)
	else:
		_phase_timer -= delta

func _on_vulnerable(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, delta * 10)
	velocity.z = move_toward(velocity.z, 0, delta * 10)