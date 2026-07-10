extends CharacterBody3D
class_name RobotEnemy

enum State { PATROLLING, ALERTED, STUNNED, DISABLED }

@export var patrol_distance := 4.0
@export var patrol_speed := 1.5
@export var alert_speed := 2.8
@export var detection_radius := 5.0
@export var stun_seconds := 2.0
@export var target_path: NodePath

var state: State = State.PATROLLING
var origin: Vector3
var direction := 1.0
var stun_timer := 0.0
var target: Node3D
var body_visual: Node3D
var shell_visual: Node3D
var eye_a: Node3D
var eye_b: Node3D
var antenna_a: Node3D
var antenna_b: Node3D
var anim_time := 0.0
var base_body_y := 0.0

func _ready() -> void:
	origin = global_position
	if target_path != NodePath(""):
		target = get_node_or_null(target_path)
	body_visual = get_node_or_null("Body")
	if body_visual:
		base_body_y = body_visual.position.y
		shell_visual = body_visual.get_node_or_null("RoundedShell")
		eye_a = body_visual.get_node_or_null("EyeA")
		eye_b = body_visual.get_node_or_null("EyeB")
		antenna_a = body_visual.get_node_or_null("AntennaA")
		antenna_b = body_visual.get_node_or_null("AntennaB")

func _physics_process(delta: float) -> void:
	match state:
		State.PATROLLING:
			_patrol(delta)
			if target and global_position.distance_to(target.global_position) <= detection_radius:
				state = State.ALERTED
		State.ALERTED:
			_chase(delta)
		State.STUNNED:
			stun_timer -= delta
			velocity = Vector3.ZERO
			if stun_timer <= 0.0:
				state = State.DISABLED
		State.DISABLED:
			velocity = Vector3.ZERO
	move_and_slide()
	_update_robot_visuals(delta)

func hit_by_environment_object(label: String) -> void:
	if state == State.DISABLED:
		return
	print("Robot aturdido con: %s" % label)
	state = State.STUNNED
	stun_timer = stun_seconds

func _patrol(_delta: float) -> void:
	velocity.x = direction * patrol_speed
	if absf(global_position.x - origin.x) > patrol_distance:
		direction *= -1.0
		look_at(global_position + Vector3(direction, 0, 0), Vector3.UP)

func _chase(_delta: float) -> void:
	if target == null:
		state = State.PATROLLING
		return
	var d: Vector3 = target.global_position - global_position
	d.y = 0
	if d.length() > detection_radius * 1.5:
		state = State.PATROLLING
		return
	var dir: Vector3 = d.normalized()
	velocity.x = dir.x * alert_speed
	velocity.z = dir.z * alert_speed
	look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)

func _update_robot_visuals(delta: float) -> void:
	if body_visual == null:
		return
	var visual_speed: float = 12.0 if state == State.ALERTED else 7.0 if state == State.PATROLLING else 16.0 if state == State.STUNNED else 2.0
	anim_time += delta * visual_speed
	var wave: float = sin(anim_time)
	var target_y: float = base_body_y
	var target_rot_z: float = 0.0
	var target_scale: Vector3 = Vector3.ONE
	match state:
		State.PATROLLING:
			target_y += absf(wave) * 0.035
			target_rot_z = wave * 0.035
		State.ALERTED:
			target_y += absf(wave) * 0.07
			target_rot_z = wave * 0.09
		State.STUNNED:
			target_y -= 0.07
			target_rot_z = wave * 0.22
			target_scale = Vector3(1.08, 0.86, 1.08)
		State.DISABLED:
			target_y -= 0.12
			target_rot_z = 0.18
			target_scale = Vector3(1.05, 0.78, 1.05)
	body_visual.position.y = lerpf(body_visual.position.y, target_y, clampf(delta * 9.0, 0.0, 1.0))
	body_visual.rotation.z = lerpf(body_visual.rotation.z, target_rot_z, clampf(delta * 9.0, 0.0, 1.0))
	body_visual.scale = body_visual.scale.lerp(target_scale, clampf(delta * 8.0, 0.0, 1.0))
	if shell_visual:
		shell_visual.rotation.z = lerpf(shell_visual.rotation.z, wave * 0.05, clampf(delta * 9.0, 0.0, 1.0))
	if antenna_a:
		antenna_a.rotation.z = lerpf(antenna_a.rotation.z, 0.45 + wave * 0.25, clampf(delta * 12.0, 0.0, 1.0))
	if antenna_b:
		antenna_b.rotation.z = lerpf(antenna_b.rotation.z, 0.45 - wave * 0.25, clampf(delta * 12.0, 0.0, 1.0))
	var eye_scale: Vector3 = Vector3.ONE * (1.0 + (0.35 if state == State.ALERTED else 0.15 if state == State.STUNNED else 0.0) * absf(wave))
	if eye_a:
		eye_a.scale = eye_a.scale.lerp(eye_scale, clampf(delta * 10.0, 0.0, 1.0))
	if eye_b:
		eye_b.scale = eye_b.scale.lerp(eye_scale, clampf(delta * 10.0, 0.0, 1.0))
