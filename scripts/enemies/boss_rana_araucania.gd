extends "res://scripts/enemies/boss_base.gd"
class_name BossGranRanaAraucania

# Gran Rana Robot del Volcán - La Araucanía
# Fase 1: Saltos con lava
# Fase 2: Lenguazo de lava
# Fase 3: Lluvia de cenizas/rocas
# Fase 4: Núcleo en la boca

@export var jump_force: float = 14.0
@export var lava_projectile_speed: float = 8.0

var _jump_timer: float = 0.0
var _lava_timer: float = 0.0

func _ready() -> void:
	super._ready()
	phase_duration = 7.0
	vulnerable_duration = 4.0
	alert_speed = 3.0
	jump_force = 14.0
	print("GRANA RANA VOLCÁN: Despertando en La Araucanía")

func _on_phase_1(delta: float) -> void:
	# Saltos grandes hacia Firipu
	if _phase_timer <= 0.0 and is_on_floor():
		velocity.y = jump_force
		_phase_timer = 2.5
		print("GRANA RANA: Salto volcánico!")
	elif target:
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = move_toward(velocity.x, dir.x * alert_speed, delta * 8)
		velocity.z = move_toward(velocity.z, dir.z * alert_speed, delta * 8)

func _on_phase_2(delta: float) -> void:
	# Lenguazo de lava (embestida rápida)
	if _phase_timer <= 0.0:
		_phase_timer = 1.5
		state = State.ALERTED
		if target:
			var dir = (target.global_position - global_position).normalized()
			dir.y = 0
			velocity.x = dir.x * alert_speed * 2.5
			velocity.z = dir.z * alert_speed * 2.5
			print("GRANA RANA: Lenguazo de lava!")
	else:
		_phase_timer -= delta

func _on_phase_3(delta: float) -> void:
	# Lluvia de cenizas - saltos más frecuentes, área de efecto
	if is_on_floor() and _phase_timer <= 0.0:
		velocity.y = jump_force * 0.8
		_phase_timer = 1.8
		print("GRANA RANA: Lluvia de cenizas!")
	else:
		super._on_phase_3(delta)

func _on_vulnerable(delta: float) -> void:
	# Abre la boca exponiendo el núcleo
	velocity.x = move_toward(velocity.x, 0, delta * 8)
	velocity.z = move_toward(velocity.z, 0, delta * 8)