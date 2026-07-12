extends "res://scripts/enemies/boss_base.gd"
class_name BossLoroTricahueMaule

# Loro Tricahue Robot del Maule - Maule
# Fase 1: Vuelo rasante con eco
# Fase 2: Picotazos en picado
# Fase 3: Llamado revelador (revela plataformas ocultas)
# Fase 4: Núcleo en el pecho

@export var dive_speed: float = 15.0
@export var eco_radius: float = 10.0

var _dive_cooldown: float = 0.0

func _ready() -> void:
	super._ready()
	phase_duration = 5.0
	vulnerable_duration = 4.0
	alert_speed = 5.0
	print("LORO TRICAHUE: Mi eco recorre los valles")

func _on_phase_1(delta: float) -> void:
	# Vuelo rasante con eco
	if _dive_cooldown <= 0.0 and target:
		_dive_cooldown = 3.0
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * 12.0
		velocity.z = dir.z * 12.0
		print("LORO TRICAHUE: Picado sónico!")
	else:
		_dive_cooldown -= delta

func _on_phase_2(delta: float) -> void:
	# Picotazos en picado repetidos
	if _dive_cooldown <= 0.0 and target:
		_dive_cooldown = 1.5
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * 18.0
		velocity.z = dir.z * 18.0
		print("LORO TRICAHUE: Picotazo certero!")
	else:
		_dive_cooldown -= delta

func _on_phase_3(delta: float) -> void:
	# Eco revelador - revela plataformas/secretos
	if _phase_timer <= 0.0:
		_phase_timer = 5.0
		print("LORO TRICAHUE: ¡Eco revelador!")
		# Revelar plataformas ocultas en radio
	else:
		_phase_timer -= delta

func _on_vulnerable(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, delta * 10)
	velocity.z = move_toward(velocity.z, 0, delta * 10)