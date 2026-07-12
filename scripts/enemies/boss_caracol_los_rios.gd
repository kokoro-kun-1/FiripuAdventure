extends "res://scripts/enemies/boss_base.gd"
class_name BossCaracolLosRios

# Caracol Blindado Espacial de la Lluvia - Los Ríos
# Fase 1: Arrastre lento con rastro de baba
# Fase 2: Caparazón giratorio defensivo
# Fase 3: Proyectiles de baba ácida
# Fase 4: Caparazón abierto (núcleo)

@export var slime_trail_duration: float = 8.0
@export var spin_speed: float = 4.0

var _spin_timer: float = 0.0
var _is_spinning: bool = false

func _ready() -> void:
	super._ready()
	phase_duration = 8.0
	vulnerable_duration = 4.0
	patrol_speed = 1.0
	alert_speed = 2.0
	print("CARACOL LLUVIA: Deslizándose por la selva valdiviana")

func _on_phase_1(delta: float) -> void:
	# Arrastre lento dejando rastro de baba
	if target:
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * patrol_speed
		velocity.z = dir.z * patrol_speed
		# Dejar rastro de baba (visual - área resbaladiza)

func _on_phase_2(delta: float) -> void:
	# Caparazón giratorio - más rápido, refleja proyectiles
	if not _is_spinning:
		_is_spinning = true
		_spin_timer = 5.0
		print("CARACOL LLUVIA: Caparazón giratorio activado!")
	
	if _is_spinning:
		rotation.y += spin_speed * delta
		_spin_timer -= delta
		if _spin_timer <= 0.0:
			_is_spinning = false
			_phase_timer = 0.0

func _on_phase_3(delta: float) -> void:
	# Proyectiles de baba ácida (simulado: embestidas rápidas con área de efecto)
	if _phase_timer <= 0.0 and target:
		_phase_timer = 2.0
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * alert_speed * 2.5
		velocity.z = dir.z * alert_speed * 2.5
		print("CARACOL LLUVIA: Proyectil de baba ácida!")

func _on_vulnerable(delta: float) -> void:
	# Caparazón abierto, núcleo expuesto en el cuerpo
	velocity.x = move_toward(velocity.x, 0, delta * 5)
	velocity.z = move_toward(velocity.z, 0, delta * 5)