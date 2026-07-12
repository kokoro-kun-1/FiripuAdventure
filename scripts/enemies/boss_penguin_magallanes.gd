extends "res://scripts/enemies/boss_base.gd"
class_name BossPenguinMagallanes

# Pingüino Robot del Hielo Austral - Magallanes
# Fase 1: Deslizamiento sobre hielo
# Fase 2: Picotazos giratorios
# Fase 3: Llamado de bandada (convoca mini-pingüinos)
# Fase 4: Núcleo en la cabeza

@export var slide_speed: float = 12.0
@export var spin_attack_speed: float = 6.0

var _slide_timer: float = 0.0

func _ready() -> void:
	super._ready()
	phase_duration = 5.0
	vulnerable_duration = 4.0
	patrol_speed = 2.0
	alert_speed = 3.0
	print("PINGÜINO AUSTRAL: El hielo es mi reino")

func _on_phase_1(delta: float) -> void:
	# Deslizamiento sobre hielo hacia Firipu
	if target and _phase_timer <= 0.0:
		_phase_timer = 2.0
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * slide_speed
		velocity.z = dir.z * slide_speed
		print("PINGÜINO AUSTRAL: Deslizamiento antártico!")
	else:
		_phase_timer -= delta

func _on_phase_2(delta: float) -> void:
	# Picotazos giratorios
	rotation.y += delta * 4.0
	if target:
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * spin_attack_speed
		velocity.z = dir.z * spin_attack_speed
		if _phase_timer <= 0.0:
			_phase_timer = 3.0
			print("PINGÜINO AUSTRAL: Picotazo giratorio!")

func _on_phase_3(delta: float) -> void:
	# Llamado de bandada - convoca mini-pingüinos (visual + área de daño)
	if _phase_timer <= 0.0:
		_phase_timer = 4.0
		print("PINGÜINO AUSTRAL: ¡Bandada antártica!")
		# Spawn mini-pingüinos (instanciar scene)

func _on_vulnerable(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, delta * 10)
	velocity.z = move_toward(velocity.z, 0, delta * 10)