extends "res://scripts/enemies/boss_base.gd"
class_name BossVaquitaAtacama

# Vaquita Robot del Desierto Florido - Atacama
# Fase 1: Carga en floración
# Fase 2: Esporas de cactus (área de ralentización)
# Fase 3: Floración explosiva (plataformas temporales)
# Fase 4: Núcleo en el pecho

@export var bloom_speed: float = 7.0
@export var platform_lifetime: float = 5.0

var _platform_timer: float = 0.0

func _ready() -> void:
	super._ready()
	phase_duration = 5.0
	vulnerable_duration = 4.0
	patrol_speed = 3.5
	alert_speed = 8.0
	print("VAQUITA FLORIDA: El desierto florece... y te vigila")

func _on_phase_1(delta: float) -> void:
	# Carga entre flores
	if target and _phase_timer <= 0.0:
		_phase_timer = 3.0
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * bloom_speed
		velocity.z = dir.z * bloom_speed
		print("VAQUITA FLORIDA: Carga entre flores!")
	else:
		_phase_timer -= delta

func _on_phase_2(delta: float) -> void:
	# Esporas de cactus - área de ralentización
	if target and _phase_timer <= 0.0:
		_phase_timer = 4.0
		print("VAQUITA FLORIDA: Esporas de cactus!")
		if target:
			target.call_deferred("apply_slow", 0.4, 3.0)
	else:
		_phase_timer -= delta

func _on_phase_3(delta: float) -> void:
	# Floración explosiva - plataformas temporales
	_platform_timer -= delta
	if _platform_timer <= 0.0:
		_platform_timer = platform_lifetime
		print("VAQUITA FLORIDA: ¡Floración explosiva!")
		# Spawn plataformas temporales (instanciar scene)
	else:
		_phase_timer -= delta

func _on_vulnerable(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, delta * 10)
	velocity.z = move_toward(velocity.z, 0, delta * 10)