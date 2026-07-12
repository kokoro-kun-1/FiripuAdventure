extends "res://scripts/enemies/boss_base.gd"
class_name BossHuemulNuble

# Huemul Robot Guardián de Ñuble
# Fase 1: Carga frontal con vapor
# Fase 2: Saltos con vapor termal
# Fase 3: Proyectiles de vapor
# Fase 4 (Vulnerable): Núcleo expuesto en el pecho

@export var charge_speed: float = 8.0
@export var jump_force: float = 12.0
@export var steam_projectile_speed: float = 10.0

var _charge_timer: float = 0.0
var _jump_cooldown: float = 0.0

func _ready() -> void:
	super._ready()
	phase_duration = 6.0
	vulnerable_duration = 4.0
	alert_speed = 4.5
	print("HUEMUL NUBLE: Guardián de las termas activado")

func _on_phase_1(delta: float) -> void:
	# Carga frontal con vapor
	if _charge_timer <= 0.0:
		_charge_timer = 3.0
		state = State.ALERTED
	else:
		_charge_timer -= delta
		# Acelerar hacia Firipu
		if target:
			var dir = (target.global_position - global_position).normalized()
			dir.y = 0
			velocity.x = dir.x * charge_speed
			velocity.z = dir.z * charge_speed

func _on_phase_2(delta: float) -> void:
	# Saltos con impulso de vapor
	if _jump_cooldown <= 0.0 and is_on_floor():
		_jump_cooldown = 2.5
		velocity.y = jump_force
		print("HUEMUL NUBLE: Salto de vapor!")
	else:
		_jump_cooldown -= delta
	# Perseguir en el aire
	if target:
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * alert_speed
		velocity.z = dir.z * alert_speed

func _on_phase_3(delta: float) -> void:
	# Proyectiles de vapor (simulado con embestidas rápidas)
	if _charge_timer <= 0.0:
		_charge_timer = 1.5
		if target:
			var dir = (target.global_position - global_position).normalized()
			dir.y = 0
			velocity.x = dir.x * (charge_speed * 1.5)
			velocity.z = dir.z * (charge_speed * 1.5)
			print("HUEMUL NUBLE: Proyectil de vapor!")
	else:
		_charge_timer -= delta

func _on_vulnerable(delta: float) -> void:
	# En fase vulnerable, el Huemul se detiene y respira
	velocity.x = move_toward(velocity.x, 0, delta * 10)
	velocity.z = move_toward(velocity.z, 0, delta * 10)
	# Yuki detecta el punto débil en el pecho