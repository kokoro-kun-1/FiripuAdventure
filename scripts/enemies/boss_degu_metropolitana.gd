extends "res://scripts/enemies/boss_base.gd"
class_name BossDeguMetropolitana

# Degú Robot de los Cerros Isla - Metropolitana
# Fase 1: Excavación y emboscada
# Fase 2: Túneles subterráneos (teletransporte)
# Fase 3: Montículo de tierra (proyectiles)
# Fase 4: Núcleo en la madriguera

@export var tunnel_speed: float = 10.0
@export var dirt_interval: float = 2.5

var _dirt_timer: float = 0.0
var _is_underground: bool = false

func _ready() -> void:
	super._ready()
	phase_duration = 5.0
	vulnerable_duration = 3.5
	patrol_speed = 3.0
	alert_speed = 8.0
	print("DEGÚ CERROS: La tierra te acoge... y te atrapa")

func _on_phase_1(delta: float) -> void:
	# Excavación y emboscada
	if not _is_underground and _phase_timer <= 0.0 and target:
		_phase_timer = 2.0
		_is_underground = true
		print("DEGÚ CERROS: ¡Excavando!")
		# Ocultarse bajo tierra (invisible)
		visible = false
		collision_layer = 0
	elif _is_underground:
		_phase_timer -= delta
		if _phase_timer <= 0.0 and target:
			# Emerger cerca de Firipu
			global_position = target.global_position + Vector3(randf_range(-3, 3), 0, randf_range(-3, 3))
			visible = true
			collision_layer = 1
			_is_underground = false
			print("DEGÚ CERROS: ¡Emboscada!")
	else:
		_phase_timer -= delta

func _on_phase_2(delta: float) -> void:
	# Túneles - teletransporte entre madrigueras
	if target and _phase_timer <= 0.0:
		_phase_timer = 3.0
		var tunnels: Array[Vector3] = [
			global_position + Vector3(10, 0, 0),
			global_position + Vector3(-10, 0, 0),
			global_position + Vector3(0, 0, 10),
			global_position + Vector3(0, 0, -10)
		]
		var dest = tunnels[randi() % tunnels.size()]
		global_position = dest
		print("DEGÚ CERROS: Túnel subterráneo!")
	else:
		_phase_timer -= delta

func _on_phase_3(delta: float) -> void:
	# Montículos de tierra - proyectiles
	_dirt_timer -= delta
	if _dirt_timer <= 0.0:
		_dirt_timer = 2.0
		print("DEGÚ CERROS: Montículo de tierra!")
		# Spawn proyectiles de tierra
	else:
		_phase_timer -= delta

func _on_vulnerable(delta: float) -> void:
	visible = true
	collision_layer = 1
	_is_underground = false
	velocity.x = move_toward(velocity.x, 0, delta * 10)
	velocity.z = move_toward(velocity.z, 0, delta * 10)