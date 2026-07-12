extends "res://scripts/enemies/boss_base.gd"
class_name BossChinchillaCoquimbo

# Chinchilla Robot de los Valles - Coquimbo
# Fase 1: Saltos ágiles entre rocas
# Fase 2: Túneles de degú (atajos subterráneos)
# Fase 3: Polvo de valle (ceguera temporal)
# Fase 4: Núcleo en la cola

@export var hop_height: float = 8.0
@export var tunnel_cooldown: float = 4.0

var _tunnel_timer: float = 0.0

func _ready() -> void:
	super._ready()
	phase_duration = 5.0
	vulnerable_duration = 3.5
	patrol_speed = 4.0
	alert_speed = 9.0
	print("CHINCHILLA VALLES: Los atajos subterráneos son mi secreto")

func _on_phase_1(delta: float) -> void:
	# Saltos ágiles entre rocas
	if target and _phase_timer <= 0.0 and is_on_floor():
		_phase_timer = 2.0
		velocity.y = hop_height
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * 6.0
		velocity.z = dir.z * 6.0
		print("CHINCHILLA VALLES: Salto entre rocas!")
	else:
		_phase_timer -= delta

func _on_phase_2(delta: float) -> void:
	# Túneles de degú - teletransporte por atajos
	_tunnel_timer -= delta
	if _tunnel_timer <= 0.0 and target:
		_tunnel_timer = tunnel_cooldown
		var offsets = [
			Vector3(8, 0, 0),
			Vector3(-8, 0, 0),
			Vector3(0, 0, 8),
			Vector3(0, 0, -8)
		]
		global_position = target.global_position + offsets[randi() % offsets.size()]
		print("CHINCHILLA VALLES: ¡Atajo subterráneo!")
	else:
		_tunnel_timer -= delta

func _on_phase_3(delta: float) -> void:
	# Polvo de valle - ceguera temporal
	if target and _phase_timer <= 0.0:
		_phase_timer = 3.0
		print("CHINCHILLA VALLES: Polvo de valle!")
		if target:
			target.call_deferred("apply_blindness", 2.5)
	else:
		_phase_timer -= delta

func _on_vulnerable(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, delta * 10)
	velocity.z = move_toward(velocity.z, 0, delta * 10)