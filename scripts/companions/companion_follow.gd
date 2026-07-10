extends CharacterBody3D
class_name CompanionFollow

@export var target_path: NodePath
@export var follow_distance := 2.0
@export var speed := 4.5
@export var companion_role := "Yuki"

var target: Node3D
var body_visual: Node3D
var head_visual: Node3D
var tail_visual: Node3D
var ear_a: Node3D
var ear_b: Node3D
var sniff_timer := 0.0
var alert_timer := 0.0
var anim_time := 0.0
var base_body_y := 0.0

func _ready() -> void:
	if target_path != NodePath(""):
		target = get_node_or_null(target_path)
	body_visual = get_node_or_null("Body")
	if body_visual:
		base_body_y = body_visual.position.y
		head_visual = body_visual.get_node_or_null("Head")
		tail_visual = body_visual.get_node_or_null("TailPuff")
		if tail_visual == null:
			tail_visual = body_visual.get_node_or_null("Tail")
		ear_a = body_visual.get_node_or_null("EarTop")
		if ear_a == null:
			ear_a = body_visual.get_node_or_null("EarA")
		ear_b = body_visual.get_node_or_null("EarB")

func _physics_process(delta: float) -> void:
	if target == null:
		_update_visual_animation(delta, false)
		return
	var delta_vec: Vector3 = target.global_position - global_position
	delta_vec.y = 0
	var dist: float = delta_vec.length()
	var moving := false
	if dist > follow_distance:
		var dir: Vector3 = delta_vec.normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
		moving = true
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()
	_update_role_reaction(dist, delta)
	_update_visual_animation(delta, moving)

func _update_role_reaction(dist: float, delta: float) -> void:
	if companion_role == "Yuki":
		# Yuki olfatea cuando está tranquila cerca de Firipu.
		if dist <= follow_distance + 0.35:
			sniff_timer = fmod(sniff_timer + delta, 2.2)
	else:
		# Kira se pone alerta cuando Firipu se acerca al sector del robot.
		if target and target.global_position.x > 12.0:
			alert_timer = minf(alert_timer + delta * 2.5, 1.0)
		else:
			alert_timer = maxf(alert_timer - delta * 2.0, 0.0)

func _update_visual_animation(delta: float, moving: bool) -> void:
	if body_visual == null:
		return
	var speed_factor: float = 12.0 if moving else 4.0
	anim_time += delta * speed_factor
	var wave: float = sin(anim_time)
	var hop: float = absf(wave) * (0.08 if moving else 0.025)
	body_visual.position.y = lerpf(body_visual.position.y, base_body_y + hop, clampf(delta * 10.0, 0.0, 1.0))
	body_visual.rotation.z = lerpf(body_visual.rotation.z, wave * (0.10 if moving else 0.025), clampf(delta * 8.0, 0.0, 1.0))
	if tail_visual:
		var tail_amp: float = 0.65 if companion_role == "Yuki" else 0.42
		tail_visual.rotation.z = lerpf(tail_visual.rotation.z, wave * tail_amp, clampf(delta * 12.0, 0.0, 1.0))
	if head_visual:
		var head_target: float = sin(anim_time * 0.7) * 0.06
		if companion_role == "Yuki" and sniff_timer > 1.25:
			head_target = 0.32
		elif companion_role == "Kira":
			head_target = -0.12 * alert_timer
		head_visual.rotation.z = lerpf(head_visual.rotation.z, head_target, clampf(delta * 9.0, 0.0, 1.0))
	if ear_a:
		ear_a.rotation.z = lerpf(ear_a.rotation.z, 0.25 + wave * 0.10 + alert_timer * 0.25, clampf(delta * 8.0, 0.0, 1.0))
	if ear_b:
		ear_b.rotation.z = lerpf(ear_b.rotation.z, -0.25 - wave * 0.10 - alert_timer * 0.25, clampf(delta * 8.0, 0.0, 1.0))

func react_to_interest(kind: String) -> void:
	if companion_role == "Yuki" and kind.to_lower().contains("fauna"):
		sniff_timer = 1.4
	if companion_role == "Kira" and kind.to_lower().contains("robot"):
		alert_timer = 1.0
	print("%s reacciona a: %s" % [companion_role, kind])
