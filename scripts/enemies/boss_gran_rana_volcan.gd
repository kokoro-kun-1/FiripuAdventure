extends "res://scripts/enemies/boss_base.gd"
class_name BossGranRanaVolcan

# Gran Rana Robot del Volcán - La Araucanía
# Fase 1: Salto volcánico con onda de choque
# Fase 2: Lava burbujeante (área de daño)
# Fase 3: Lengua de magma (proyectil)
# Fase 4: Núcleo en la garganta

@export var jump_power: float = 18.0
@export var lava_interval: float = 3.0

var _lava_timer: float = 0.0

func _ready() -> void:
	super._ready()
	phase_duration = 6.0
	vulnerable_duration = 4.0
	patrol_speed = 3.0
	alert_speed = 10.0
	print("GRANA RANA VOLCÁN: El volcán ruge bajo tus pies")

func _on_phase_1(delta: float) -> void:
	# Salto volcánico con onda de choque
	if target and _phase_timer <= 0.0:
		_phase_timer = 4.0
		velocity.y = jump_power
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * 8.0
		velocity.z = dir.z * 8.0
		print("GRANA RANA: ¡Salto volcánico!")
	else:
		_phase_timer -= delta

func _on_phase_2(delta: float) -> void:
	# Lava burbujeante - área de daño alrededor
	_lava_timer -= delta
	if _lava_timer <= 0.0:
		_lava_timer = lava_interval
		print("GRANA RANA: Lava burbujeante!")
		# Crear área de lava alrededor (instanciar scene)
	else:
		_phase_timer -= delta

func _on_phase_3(delta: float) -> void:
	# Lengua de magma - proyectil dirigido
	if target and _phase_timer <= 0.0:
		_phase_timer = 3.0
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		# Spawn proyectil de magma (instanciar scene)
		print("GRANA RANA: Lengua de magma!")
	else:
		_phase_timer -= delta

func _on_vulnerable(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, delta * 10)
	velocity.z = move_toward(velocity.z, 0, delta * 10)