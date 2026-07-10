extends Camera3D

@export var target_path: NodePath
@export var follow_speed := 6.5
@export var fixed_y := 7.2
@export var fixed_z := 24.0
@export var x_offset := 2.8
@export var look_height := 1.55
@export var dead_zone_x := 0.65
@export var min_x := -24.5
@export var max_x := 25.5

var target: Node3D
var desired_x := 0.0

func _ready() -> void:
	projection = Camera3D.PROJECTION_ORTHOGONAL
	size = 12.6
	current = true
	if target_path != NodePath(""):
		target = get_node_or_null(target_path)
	if target:
		desired_x = clampf(target.global_position.x + x_offset, min_x, max_x)
		global_position = Vector3(desired_x, fixed_y, fixed_z)
		look_at(Vector3(desired_x, look_height, 0.0), Vector3.UP)

func _process(delta: float) -> void:
	if target == null:
		return
	var target_x: float = clampf(target.global_position.x + x_offset, min_x, max_x)
	if absf(target_x - desired_x) > dead_zone_x:
		desired_x = target_x - signf(target_x - desired_x) * dead_zone_x
	var desired: Vector3 = Vector3(desired_x, fixed_y, fixed_z)
	global_position = global_position.lerp(desired, clamp(follow_speed * delta, 0.0, 1.0))
	look_at(Vector3(global_position.x, look_height, 0.0), Vector3.UP)
