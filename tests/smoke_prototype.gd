extends SceneTree

func _action_has_joy_button(action_name: String, button_index: JoyButton) -> bool:
	for event in InputMap.action_get_events(action_name):
		if event is InputEventJoypadButton and event.button_index == button_index:
			return true
	return false

func _action_has_joy_axis(action_name: String, axis: JoyAxis, axis_value: float) -> bool:
	for event in InputMap.action_get_events(action_name):
		if event is InputEventJoypadMotion and event.axis == axis and signf(event.axis_value) == signf(axis_value):
			return true
	return false

func _initialize() -> void:
	var scene: PackedScene = load("res://scenes/levels/level_biobio_prototype.tscn")
	if scene == null:
		push_error("No se pudo cargar level_biobio_prototype.tscn")
		quit(1)
		return

	var level: Node = scene.instantiate()
	root.add_child(level)
	await process_frame
	await process_frame

	var player: Node = level.get_node_or_null("Firipu")
	if player == null:
		push_error("No existe nodo Firipu")
		quit(1)
		return

	var camera: Node = level.get_node_or_null("SideCamera")
	if camera == null or not camera.current:
		push_error("Cámara lateral no está activa")
		quit(1)
		return

	var hud: Node = level.get_node_or_null("HUD")
	if hud == null:
		push_error("No existe HUD")
		quit(1)
		return

	if level.has_method("get_flow_status"):
		var status: Dictionary = level.get_flow_status()
		if not status.get("started", false):
			push_error("Flujo de mundo no inició")
			quit(1)
			return

	var start_panel: CanvasItem = hud.get_node_or_null("StartPanel")
	if start_panel == null or not start_panel.visible:
		push_error("Pantalla inicial no está visible")
		quit(1)
		return
	if hud.has_method("start_game"):
		hud.start_game()
	await process_frame
	if start_panel.visible:
		push_error("Pantalla inicial no se ocultó al comenzar")
		quit(1)
		return
	if player.get("input_locked"):
		push_error("Firipu siguió bloqueado tras comenzar")
		quit(1)
		return
	if not _action_has_joy_button("jump", JOY_BUTTON_A):
		push_error("Falta salto Xbox con botón A")
		quit(1)
		return
	if not _action_has_joy_button("interact", JOY_BUTTON_X):
		push_error("Falta interactuar Xbox con botón X")
		quit(1)
		return
	if not _action_has_joy_button("use_item", JOY_BUTTON_RIGHT_SHOULDER):
		push_error("Falta usar objeto Xbox con RB")
		quit(1)
		return
	if not _action_has_joy_axis("move_right", JOY_AXIS_LEFT_X, 1.0):
		push_error("Falta movimiento Xbox con stick izquierdo")
		quit(1)
		return

	player.global_position.z = 99.0
	for i in range(4):
		await physics_frame
	if abs(player.global_position.z) > player.depth_limit + 0.05:
		push_error("Límite de profundidad 2.5D no se respeta")
		quit(1)
		return

	var expected := ["Chinita", "Abejorro", "Libelula", "RanitaPequena"]
	for node_name in expected:
		var collectible: Node = level.get_node_or_null(node_name)
		if collectible == null:
			push_error("Falta coleccionable: %s" % node_name)
			quit(1)
			return
		collectible.interact(player)

	if player.collected != 4:
		push_error("Contador de fauna incorrecto: %d" % player.collected)
		quit(1)
		return

	var piedra: Node = level.get_node_or_null("Piedra")
	if piedra == null:
		push_error("Falta Piedra")
		quit(1)
		return
	piedra.interact(player)
	if player.held_object != "Piedra":
		push_error("No tomó Piedra")
		quit(1)
		return

	var robot: Node = level.get_node_or_null("EscarabajoRobot")
	if robot == null:
		push_error("Falta EscarabajoRobot")
		quit(1)
		return
	robot.hit_by_environment_object(player.held_object)
	if robot.state != robot.State.STUNNED:
		push_error("Robot no quedó aturdido")
		quit(1)
		return

	player.obtain_medal()
	await process_frame
	if not player.medal_obtained:
		push_error("Medalla no obtenida tras 4 coleccionables")
		quit(1)
		return
	if level.has_method("get_flow_status"):
		var final_status: Dictionary = level.get_flow_status()
		if not final_status.get("victory", false):
			push_error("Flujo de victoria no quedó activo")
			quit(1)
			return

	var victory_panel: CanvasItem = hud.get_node_or_null("VictoryPanel")
	if victory_panel == null or not victory_panel.visible:
		push_error("Panel de victoria no está visible")
		quit(1)
		return

	print("SMOKE_TEST_OK prototipo_0_1_25D_flow")
	quit(0)
