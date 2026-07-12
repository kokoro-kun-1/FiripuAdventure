extends "res://scripts/enemies/boss_base.gd"
class_name BossHuemulGlacialAysen

# Huemul Robot Glacial de Aysén - Aysén
# Fase 1: Carga con cuernos de hielo
# Fase 2: Estampida glacial
# Fase 3: Ventisca cegadora
# Fase 4: Núcleo en el pecho

@export var charge_speed: float = 10.0
@export var blizzard_radius: float = 8.0

var _charge_cooldown: float = 0.0

func _ready() -> void:
	super._ready()
	phase_duration = 6.0
	vulnerable_duration = 4.0
	alert_speed = 4.0
	charge_speed = 10.0
	print("HUEMUL GLACIAL: El hielo corre por mis venas")

func _on_phase_1(delta: float) -> void:
	# Carga con cuernos de hielo
	if _charge_cooldown <= 0.0 and target:
		_charge_cooldown = 4.0
		state = State.ALERTED
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * charge_speed
		velocity.z = dir.z * charge_speed
		print("HUEMUL GLACIAL: Carga de cuernos!")
	else:
		_charge_cooldown -= delta

func _on_phase_2(delta: float) -> void:
	# Estampida - múltiples cargas rápidas
	if _charge_cooldown <= 0.0 and target:
		_charge_cooldown = 1.5
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * charge_speed * 1.3
		velocity.z = dir.z * charge_speed * 1.3
		print("HUEMUL GLACIAL: Estampida!")
	else:
		_charge_cooldown -= delta

func _on_phase_3(delta: float) -> void:
	# Ventisca cegadora - reduce visibilidad
	if _phase_timer <= 0.0:
		_phase_timer = 4.0
		print("HUEMUL GLACIAL: Ventisca cegadora!")
		# Aplicar efecto visual de nieve densa
	else:
		_phase_timer -= delta

func _on_vulnerable(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, delta * 10)
	velocity.z = move_toward(velocity.z, 0, delta * 10)