extends "res://scripts/enemies/boss_base.gd"
class_name BossEscarabajoCobreAntofagasta

# Escarabajo de Cobre Cósmico - Antofagasta
# Fase 1: Carga metálica con rastro de cobre
# Fase 2: Campo magnético (atrae/repulsión)
# Fase 3: Descarga eléctrica en cadena
# Fase 4: Núcleo en el caparazón

@export var magnetic_radius: float = 10.0
@export var magnetic_force: float = 15.0
@export var lightning_interval: float = 3.0

var _lightning_timer: float = 0.0

func _ready() -> void:
	super._ready()
	phase_duration = 5.0
	vulnerable_duration = 4.0
	patrol_speed = 3.0
	alert_speed = 9.0
	print("ESCARABAJO COBRE: El desierto brilla con tu presencia")

func _on_phase_1(delta: float) -> void:
	# Carga metálica con rastro de cobre conductor
	if target and _phase_timer <= 0.0:
		_phase_timer = 3.0
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * 7.0
		velocity.z = dir.z * 7.0
		print("ESCARABAJO COBRE: Carga de cobre puro!")
	else:
		_phase_timer -= delta

func _on_phase_2(delta: float) -> void:
	# Campo magnético - atrae o repele objetos metálicos
	if target:
		var dist = global_position.distance_to(target.global_position)
		if dist < magnetic_radius:
			var dir = (target.global_position - global_position).normalized()
			dir.y = 0
			# Repulsión magnética
			target.call_deferred("apply_force", -dir * magnetic_force)
			print("ESCARABAJO COBRE: ¡Campo magnético activado!")
	else:
		_phase_timer -= delta

func _on_phase_3(delta: float) -> void:
	# Descarga eléctrica en cadena
	_lightning_timer -= delta
	if _lightning_timer <= 0.0:
		_lightning_timer = lightning_interval
		print("ESCARABAJO COBRE: ¡Descarga cósmica!")
		if target:
			target.call_deferred("apply_shock", 2.0)
	else:
		_phase_timer -= delta

func _on_vulnerable(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, delta * 10)
	velocity.z = move_toward(velocity.z, 0, delta * 10)