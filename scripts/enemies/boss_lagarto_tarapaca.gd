extends "res://scripts/enemies/boss_base.gd"
class_name BossLagartoTarapaca

# Lagarto Robot de los Espejismos - Tarapacá
# Fase 1: Camuflaje de espejismo
# Fase 2: Arena movediza (trampa)
# Fase 3: Ilusiones múltiples (clones)
# Fase 4: Núcleo en el ojo

@export var illusion_duration: float = 6.0
@export var quicksand_radius: float = 5.0

var _illusion_timer: float = 0.0

func _ready() -> void:
	super._ready()
	phase_duration = 5.0
	vulnerable_duration = 4.0
	patrol_speed = 3.0
	alert_speed = 8.0
	print("LAGARTO ESPEJISMOS: Lo que ves... no es real")

func _on_phase_1(delta: float) -> void:
	# Camuflaje - se vuelve semitransparente
	if _phase_timer <= 0.0:
		_phase_timer = 3.0
		print("LAGARTO ESPEJISMOS: ¡Camuflaje activado!")
		# Visual: modular opacidad del material 3D (no modulate, es solo 2D)
		_set_body_alpha(0.4)
		visible = true
	else:
		_phase_timer -= delta

func _set_body_alpha(a: float) -> void:
	var body := get_node_or_null("Body") as MeshInstance3D
	if body == null:
		return
	var mat := body.get_active_material(0) as BaseMaterial3D
	if mat == null:
		return
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if mat is StandardMaterial3D:
		(mat as StandardMaterial3D).albedo_color.a = a

func _on_phase_2(delta: float) -> void:
	# Arena movediza - área que atrapa
	if target and _phase_timer <= 0.0:
		_phase_timer = 5.0
		var dist = global_position.distance_to(target.global_position)
		if dist < quicksand_radius:
			target.call_deferred("apply_slow", 0.2, 4.0)
			print("LAGARTO ESPEJISMOS: ¡Arena movediza!")
	else:
		_phase_timer -= delta

func _on_phase_3(delta: float) -> void:
	# Ilusiones - spawn clones visuales
	if _illusion_timer <= 0.0:
		_illusion_timer = illusion_duration
		print("LAGARTO ESPEJISMOS: ¡Ilusiones múltiples!")
		# Spawn clones visuales (sin colisión)
	else:
		_illusion_timer -= delta
		_phase_timer -= delta

func _on_vulnerable(delta: float) -> void:
	# Camuflaje roto - totalmente visible
	_set_body_alpha(1.0)
	velocity.x = move_toward(velocity.x, 0, delta * 10)
	velocity.z = move_toward(velocity.z, 0, delta * 10)