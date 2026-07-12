extends "res://scripts/enemies/boss_base.gd"
class_name BossPicaflorAltiplano

# Picaflor Cósmico del Altiplano - Arica y Parinacota
# Fase 1: Vuelo supersónico en zigzag
# Fase 2: Néctar cósmico (proyectiles que curan al boss)
# Fase 3: Parada temporal (time dilation local)
# Fase 4: Núcleo en el pico

@export var sonic_speed: float = 20.0
@export var time_dilation_factor: float = 0.3

var _sonic_timer: float = 0.0
var _time_dilation_active: bool = false

func _ready() -> void:
	super._ready()
	phase_duration = 5.0
	vulnerable_duration = 3.5
	patrol_speed = 6.0
	alert_speed = 18.0
	print("PICAFLOR ALTIPLANO: Las estrellas cantan en tu honor")

func _on_phase_1(delta: float) -> void:
	# Vuelo supersónico en zigzag
	if target and _phase_timer <= 0.0:
		_phase_timer = 2.0
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		# Zigzag pattern
		dir = dir.rotated(Vector3.UP, randf_range(-0.5, 0.5))
		velocity.x = dir.x * sonic_speed
		velocity.z = dir.z * sonic_speed
		print("PICAFLOR ALTIPLANO: ¡Vuelo supersónico!")
	else:
		_phase_timer -= delta

func _on_phase_2(delta: float) -> void:
	# Néctar cósmico - proyectiles que curan al boss si golpean
	if target and _phase_timer <= 0.0:
		_phase_timer = 3.0
		print("PICAFLOR ALTIPLANO: Néctar estelar!")
		# Spawn proyectiles de néctar (instanciar scene)
	else:
		_phase_timer -= delta

func _on_phase_3(delta: float) -> void:
	# Time dilation local - ralentiza a Firipu en área
	if not _time_dilation_active:
		_time_dilation_active = true
		_sonic_timer = 4.0
		print("PICAFLOR ALTIPLANO: ¡El tiempo se detiene!")
	
	if _time_dilation_active:
		_sonic_timer -= delta
		if target:
			target.call_deferred("apply_time_dilation", time_dilation_factor, 0.5)
		if _sonic_timer <= 0.0:
			_time_dilation_active = false
			_phase_timer = 0.0
	else:
		_phase_timer -= delta

func _on_vulnerable(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, delta * 10)
	velocity.z = move_toward(velocity.z, 0, delta * 10)