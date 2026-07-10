extends CharacterBody3D
class_name FiripuController

signal collected_changed(count: int, total: int)
signal medal_state_changed(text: String)
signal object_changed(text: String)
signal action_hint_changed(text: String)
signal movement_state_changed(text: String)
signal prototype_completed

@export var walk_speed := 4.2
@export var run_speed := 6.8
@export var jump_velocity := 6.4
@export var dodge_speed := 10.5
@export var gravity := 19.0
@export var total_collectibles := 4
@export var depth_limit := 2.2
@export var ground_acceleration := 18.0
@export var air_acceleration := 8.0
@export var lane_return_speed := 7.5
@export var coyote_time := 0.12
@export var jump_buffer_time := 0.14

var collected := 0
var held_object := "Ninguno"
var medal_obtained := false
var nearby_interactable: Node = null
var dodge_timer := 0.0
var facing_dir := 1.0
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var movement_state := "quieto"
var input_locked := false
var body_visual: Node3D
var body_base_scale := Vector3.ONE
var visual_bob_time := 0.0
var arm_front: Node3D
var arm_back: Node3D
var leg_front: Node3D
var leg_back: Node3D
var head_visual: Node3D
var cap_visual: Node3D
var backpack_visual: Node3D

func _ready() -> void:
	_ensure_input_actions()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	body_visual = get_node_or_null("Body")
	if body_visual:
		body_base_scale = body_visual.scale
		arm_front = body_visual.get_node_or_null("ArmFront")
		arm_back = body_visual.get_node_or_null("ArmBack")
		leg_front = body_visual.get_node_or_null("LegFront")
		leg_back = body_visual.get_node_or_null("LegBack")
		head_visual = body_visual.get_node_or_null("Head")
		cap_visual = body_visual.get_node_or_null("Cap")
		backpack_visual = body_visual.get_node_or_null("Backpack")
	_emit_hud()
	_set_action_hint("Teclado: A/D/W/S, Espacio, E, Click · Xbox: Stick izq., A saltar, X interactuar, RB usar objeto")
	_set_movement_state("quieto")

func _ensure_input_actions() -> void:
	_add_key_action("move_forward", KEY_W)
	_add_key_action("move_back", KEY_S)
	_add_key_action("move_left", KEY_A)
	_add_key_action("move_right", KEY_D)
	_add_key_action("run", KEY_SHIFT)
	_add_key_action("jump", KEY_SPACE)
	_add_key_action("dodge", KEY_CTRL)
	_add_key_action("interact", KEY_E)
	_add_mouse_action("use_item", MOUSE_BUTTON_LEFT)

	# Mando Xbox / XInput: stick izquierdo para movimiento, botones para acciones.
	_add_joy_axis_action("move_left", JOY_AXIS_LEFT_X, -1.0)
	_add_joy_axis_action("move_right", JOY_AXIS_LEFT_X, 1.0)
	_add_joy_axis_action("move_forward", JOY_AXIS_LEFT_Y, -1.0)
	_add_joy_axis_action("move_back", JOY_AXIS_LEFT_Y, 1.0)
	_add_joy_button_action("jump", JOY_BUTTON_A)
	_add_joy_button_action("interact", JOY_BUTTON_X)
	_add_joy_button_action("use_item", JOY_BUTTON_RIGHT_SHOULDER)
	_add_joy_button_action("use_item", JOY_BUTTON_RIGHT_STICK)
	_add_joy_button_action("dodge", JOY_BUTTON_B)
	_add_joy_button_action("run", JOY_BUTTON_LEFT_SHOULDER)
	_add_joy_axis_action("run", JOY_AXIS_TRIGGER_LEFT, 1.0)
	_add_joy_axis_action("run", JOY_AXIS_TRIGGER_RIGHT, 1.0)
	_add_joy_button_action("ui_accept", JOY_BUTTON_A)
	_add_joy_button_action("ui_accept", JOY_BUTTON_START)

func _ensure_action(action_name: String) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

func _add_key_action(action_name: String, keycode: Key) -> void:
	_ensure_action(action_name)
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action_name, event)

func _add_mouse_action(action_name: String, button_index: MouseButton) -> void:
	_ensure_action(action_name)
	var mouse_event := InputEventMouseButton.new()
	mouse_event.button_index = button_index
	InputMap.action_add_event(action_name, mouse_event)

func _add_joy_button_action(action_name: String, button_index: JoyButton) -> void:
	_ensure_action(action_name)
	var joy_event := InputEventJoypadButton.new()
	joy_event.button_index = button_index
	InputMap.action_add_event(action_name, joy_event)

func _add_joy_axis_action(action_name: String, axis: JoyAxis, axis_value: float) -> void:
	_ensure_action(action_name)
	var joy_event := InputEventJoypadMotion.new()
	joy_event.axis = axis
	joy_event.axis_value = axis_value
	InputMap.action_add_event(action_name, joy_event)

func _unhandled_input(event: InputEvent) -> void:
	if input_locked:
		return
	if event.is_action_pressed("interact"):
		_interact()
	if event.is_action_pressed("use_item"):
		_use_item()
	if event.is_action_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

func set_input_locked(locked: bool) -> void:
	input_locked = locked
	if input_locked:
		velocity = Vector3.ZERO
		_set_movement_state("quieto")

func _physics_process(delta: float) -> void:
	if input_locked:
		_update_placeholder_animation("quieto", delta)
		return
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
		velocity.y -= gravity * delta

	jump_buffer_timer = maxf(jump_buffer_timer - delta, 0.0)

	var x_input := Input.get_axis("move_left", "move_right")
	var z_input := Input.get_axis("move_forward", "move_back")
	var speed := run_speed if Input.is_action_pressed("run") else walk_speed
	var accel := ground_acceleration if is_on_floor() else air_acceleration

	if abs(x_input) > 0.01:
		facing_dir = sign(x_input)
		rotation.y = deg_to_rad(90.0) if facing_dir > 0.0 else deg_to_rad(-90.0)

	if Input.is_action_just_pressed("dodge") and dodge_timer <= 0.0 and is_on_floor():
		dodge_timer = 0.22
		_set_action_hint("¡Firipu esquivó rápido!")

	if dodge_timer > 0.0:
		dodge_timer -= delta
		velocity.x = facing_dir * dodge_speed
	else:
		velocity.x = move_toward(velocity.x, x_input * speed, accel * delta)

	# Profundidad limitada: el mundo es lateral 2.5D, no 3D libre.
	var target_z_velocity := z_input * (speed * 0.50)
	if abs(z_input) <= 0.01:
		target_z_velocity = -global_position.z * lane_return_speed
	velocity.z = move_toward(velocity.z, target_z_velocity, accel * delta)

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		_set_action_hint("¡Buen salto!")

	move_and_slide()
	global_position.z = clamp(global_position.z, -depth_limit, depth_limit)
	_update_movement_state(x_input, delta)

func _update_movement_state(x_input: float, delta: float) -> void:
	var next_state := "quieto"
	if not is_on_floor():
		next_state = "saltar" if velocity.y > 0.0 else "caer"
	elif dodge_timer > 0.0:
		next_state = "esquivar"
	elif abs(x_input) > 0.05:
		next_state = "correr" if Input.is_action_pressed("run") else "caminar"
	_set_movement_state(next_state)
	_update_placeholder_animation(next_state, delta)

func _update_placeholder_animation(state: String, delta: float) -> void:
	if body_visual == null:
		return
	var anim_speed: float = 13.0 if state == "correr" else 9.0 if state == "caminar" else 5.0
	visual_bob_time += delta * anim_speed
	var wave: float = sin(visual_bob_time)
	var counter_wave: float = sin(visual_bob_time + PI)
	var target_scale: Vector3 = body_base_scale
	var target_y: float = 0.0
	var lean_z: float = 0.0
	match state:
		"caminar", "correr":
			target_y = absf(wave) * 0.055
			target_scale = body_base_scale * Vector3(1.0, 0.96 + absf(wave) * 0.07, 1.0)
			lean_z = -0.10 if state == "correr" else -0.05
			_set_limb_rotation(arm_front, wave * 0.65)
			_set_limb_rotation(arm_back, counter_wave * 0.65)
			_set_limb_rotation(leg_front, counter_wave * 0.50)
			_set_limb_rotation(leg_back, wave * 0.50)
		"saltar":
			target_scale = body_base_scale * Vector3(0.92, 1.13, 0.92)
			lean_z = -0.16
			_set_limb_rotation(arm_front, -0.95)
			_set_limb_rotation(arm_back, -0.65)
			_set_limb_rotation(leg_front, 0.35)
			_set_limb_rotation(leg_back, -0.35)
		"caer":
			target_scale = body_base_scale * Vector3(1.08, 0.92, 1.08)
			lean_z = 0.08
			_set_limb_rotation(arm_front, 0.70)
			_set_limb_rotation(arm_back, 0.55)
			_set_limb_rotation(leg_front, -0.12)
			_set_limb_rotation(leg_back, 0.12)
		"esquivar":
			target_scale = body_base_scale * Vector3(1.18, 0.78, 1.18)
			target_y = -0.10
			lean_z = -0.35
			_set_limb_rotation(arm_front, -1.15)
			_set_limb_rotation(arm_back, -0.85)
			_set_limb_rotation(leg_front, 0.85)
			_set_limb_rotation(leg_back, -0.55)
		_:
			target_scale = body_base_scale * Vector3(1.0, 1.0 + sin(visual_bob_time) * 0.018, 1.0)
			_set_limb_rotation(arm_front, -0.18 + sin(visual_bob_time) * 0.04)
			_set_limb_rotation(arm_back, 0.20 - sin(visual_bob_time) * 0.04)
			_set_limb_rotation(leg_front, 0.03)
			_set_limb_rotation(leg_back, -0.03)
	body_visual.scale = body_visual.scale.lerp(target_scale, clampf(delta * 12.0, 0.0, 1.0))
	body_visual.position.y = lerpf(body_visual.position.y, target_y, clampf(delta * 10.0, 0.0, 1.0))
	body_visual.rotation.z = lerpf(body_visual.rotation.z, lean_z, clampf(delta * 10.0, 0.0, 1.0))
	if head_visual:
		head_visual.rotation.z = lerpf(head_visual.rotation.z, -lean_z * 0.30 + sin(visual_bob_time * 0.5) * 0.025, clampf(delta * 8.0, 0.0, 1.0))
	if backpack_visual:
		backpack_visual.rotation.z = lerpf(backpack_visual.rotation.z, -wave * 0.07, clampf(delta * 8.0, 0.0, 1.0))
	if cap_visual:
		cap_visual.rotation.z = lerpf(cap_visual.rotation.z, -lean_z * 0.2, clampf(delta * 8.0, 0.0, 1.0))

func _set_limb_rotation(node: Node3D, angle: float) -> void:
	if node == null:
		return
	node.rotation.z = lerpf(node.rotation.z, angle, 0.35)

func _set_movement_state(text: String) -> void:
	if movement_state == text:
		return
	movement_state = text
	movement_state_changed.emit(movement_state)

func register_collectible(label: String) -> void:
	collected = clamp(collected + 1, 0, total_collectibles)
	print("Fauna registrada: %s (%d/%d)" % [label, collected, total_collectibles])
	_set_action_hint("¡Encontraste %s! Diario de Naturaleza actualizado." % label)
	_emit_hud()

func set_nearby_interactable(node: Node) -> void:
	nearby_interactable = node
	_set_action_hint("Presione E para interactuar con %s" % node.name)

func clear_nearby_interactable(node: Node) -> void:
	if nearby_interactable == node:
		nearby_interactable = null
		_set_action_hint("Explore el sendero lateral del Biobío")

func pick_environment_object(label: String) -> void:
	held_object = label
	object_changed.emit(held_object)
	_set_action_hint("Objeto listo: %s. Click para usarlo contra el robot." % label)

func obtain_medal() -> void:
	if medal_obtained:
		return
	if collected < total_collectibles:
		medal_state_changed.emit("Faltan coleccionables: %d/%d" % [collected, total_collectibles])
		_set_action_hint("Aún falta registrar toda la fauna antes de tomar la medalla.")
		return
	medal_obtained = true
	medal_state_changed.emit("¡Medalla del Bosque y Río del Biobío conseguida!")
	_set_action_hint("Mundo 1 completado: Biobío protegido.")
	print("PROTOTIPO 0.1 COMPLETADO")
	prototype_completed.emit()

func _interact() -> void:
	if nearby_interactable and nearby_interactable.has_method("interact"):
		nearby_interactable.interact(self)

func _use_item() -> void:
	if held_object == "Ninguno":
		_set_action_hint("No tiene objeto. Busque una piedra o rama.")
		return
	var space_state := get_world_3d().direct_space_state
	var from := global_position + Vector3.UP * 0.8
	var to := from + Vector3(facing_dir * 5.0, 0.0, 0.0)
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var hit := space_state.intersect_ray(query)
	if hit and hit.collider and hit.collider.has_method("hit_by_environment_object"):
		hit.collider.hit_by_environment_object(held_object)
		held_object = "Ninguno"
		object_changed.emit(held_object)
		_set_action_hint("¡Buen tiro! El robot quedó vulnerable.")
	else:
		_set_action_hint("El objeto no alcanzó nada. Acerque a Firipu al robot.")

func _emit_hud() -> void:
	collected_changed.emit(collected, total_collectibles)
	object_changed.emit(held_object)

func _set_action_hint(text: String) -> void:
	action_hint_changed.emit(text)

# --- Getters and Setters for SaveSystem ---

func get_collected() -> int:
	return collected

func set_collected(value: int) -> void:
	collected = clamp(value, 0, total_collectibles)
	_emit_hud()

func get_medal_obtained() -> bool:
	return medal_obtained

func set_medal_obtained(value: bool) -> void:
	medal_obtained = value
	if medal_obtained:
		medal_state_changed.emit("¡Medalla del Bosque y Río del Biobío conseguida!")
		_set_action_hint("Mundo 1 completado: Biobío protegido.")
	else:
		medal_state_changed.emit("Medalla: Pendiente")
		_set_action_hint("Aún falta registrar toda la fauna antes de tomar la medalla.")

# Optional: expose held_object if needed
func get_held_object() -> String:
	return held_object

func set_held_object(value: String) -> void:
	held_object = value
	object_changed.emit(held_object)