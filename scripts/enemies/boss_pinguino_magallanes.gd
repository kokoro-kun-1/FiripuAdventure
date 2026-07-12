extends "res://scripts/enemies/boss_base.gd"
class_name BossPinguinoMagallanes

# Pingüino Robot del Hielo Austral - Magallanes
# Fase 1: Deslizamiento sobre hielo
# Fase 2: Llamada de manada (spawn pingüinitos)
# Fase 3: Onda de choque helada
# Fase 4: Núcleo en el pico

@export var slide_speed: float = 10.0
@export var spawn_interval: float = 8.0

var _spawn_timer: float = 0.0

func _ready() -> void:
	super._ready()
	phase_duration = 5.0
	vulnerable_duration = 3.0
	patrol_speed = 2.0
	alert_speed = 10.0
	print("PINGÜINO AUSTRAL: El hielo te espera")

func _on_phase_1(delta: float) -> void:
	# Deslizamiento rápido sobre hielo
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
	# Llamada de manada - spawn pingüinitos
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = spawn_interval
		print("PINGÜINO AUSTRAL: ¡Llamada de manada!")
		# Spawn pingüinitos robot pequeños (instanciar scene)

func _on_phase_3(delta: float) -> void:
	# Onda de choque helada - área circular
	if target and _phase_timer <= 0.0:
		_phase_timer = 3.0
		var dist = global_position.distance_to(target.global_position)
		if dist < 12.0:
			# Congelar temporalmente
			target.call_deferred("apply_freeze", 2.0)
		print("PINGÜINO AUSTRAL: Onda de choque helada!")
	else:
		_phase_timer -= delta

func _on_vulnerable(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, delta * 10)
	velocity.z = move_toward(velocity.z, 0, delta * 10)