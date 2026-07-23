extends Node3D

const ROUTE_START_X := -440.0
const ROUTE_END_X := 440.0
const ROUTE_LENGTH_M := ROUTE_END_X - ROUTE_START_X
const SEGMENT_CHECKPOINTS := [-440.0, -260.0, -80.0, 100.0, 330.0]
const GATE_POSITIONS := [-260.0, -80.0, 100.0, 330.0]
const OPTIMAL_INTERACTION_SECONDS := 101.0

@onready var player: Node = $Firipu
@onready var hud: Node = $HUD
@onready var medal_area: Area3D = $MedalArea
@onready var robot: Node = $EscarabajoRobot
@onready var boss: Node = $BossCosmicBeetle
@onready var yuki: Node = $Yuki
@onready var bike: Node = $Bike

var flow_started := false
var victory_reached := false
var gameplay_started := false
var world_completed := false
# Reference to savegame singleton
var save_game : Node

func _ready() -> void:
	_configure_expanded_layout()

	if hud.has_method("bind_player"):
		hud.bind_player(player)
		if player.has_signal("collected_changed"):
			player.collected_changed.connect(_on_route_progress_changed)
		if hud.has_signal("start_requested"):
			hud.start_requested.connect(_on_start_requested)
		if hud.has_signal("save_requested"):
			hud.save_requested.connect(_on_save_requested)
		if hud.has_signal("load_requested"):
			hud.load_requested.connect(_on_load_requested)
		if hud.has_signal("exit_requested"):
			hud.exit_requested.connect(_on_exit_requested)
		if player.has_method("set_input_locked"):
			player.set_input_locked(true)
		medal_area.body_entered.connect(_on_medal_area_body_entered)
		medal_area.monitoring = false
		if player.has_signal("prototype_completed"):
			player.prototype_completed.connect(_on_prototype_completed)
	if boss != null and boss.has_signal("boss_defeated"):
		boss.boss_defeated.connect(_on_boss_defeated)
	_start_world_flow()
	print("Firipu Adventure prototipo 0.1 — Biobío Silvestre iniciado")
	
	# Get singleton
	var root = get_tree().root
	if root.has_node("SaveGame"):
		save_game = root.get_node("SaveGame")
	else:
		push_error("SaveGame autoload not found!")

func _start_world_flow() -> void:
	flow_started = true
	if hud.has_method("show_message"):
		hud.show_message("Presione Enter para comenzar. Objetivo: registre 4 especies, use un objeto contra el robot y tome la medalla.")
	print("FLOW_START Mundo 1 Biobío")

func _on_start_requested() -> void:
	gameplay_started = true
	if player.has_method("set_input_locked"):
		player.set_input_locked(false)
	print("FLOW_GAMEPLAY_START Mundo 1 Biobío")

func _on_save_requested() -> void:
	if save_game == null:
		push_warning("Level: SaveGame autoload not available.")
		return
	save_game.save_game(self)
	if hud.has_method("show_message"):
		hud.show_message("Partida guardada.")

func _on_load_requested() -> void:
	if save_game == null:
		push_warning("Level: SaveGame autoload not available.")
		return
	save_game.load_game(self)
	if hud.has_method("show_message"):
		hud.show_message("Partida cargada.")

func _on_exit_requested() -> void:
	print("FLOW_EXIT_REQUESTED Mundo 1 Biobío")
	get_tree().quit(0)

func _on_medal_area_body_entered(body: Node) -> void:
	if body == player and bool(boss.get("defeated")) and int(player.get("collected")) >= 4 and player.has_method("obtain_medal"):
		player.obtain_medal()
	elif body == player and hud.has_method("show_message"):
		hud.show_message("La medalla se libera al completar el Diario y desactivar al jefe.")

func _on_prototype_completed() -> void:
	set_world_completed(true)
	var global_progress := get_node_or_null("/root/GlobalProgress")
	if global_progress != null:
		global_progress.complete_world("biobio")
		global_progress.force_save()
	print("FLOW_VICTORY Mundo 1 Biobío")
	
	# Autosave when world completed
	_on_save_requested()

func set_world_completed(completed: bool) -> void:
	world_completed = completed
	victory_reached = completed
	if completed and hud != null and hud.has_method("show_victory"):
		hud.show_victory()

func get_world_completed() -> bool:
	return world_completed

func get_flow_status() -> Dictionary:
	return {
		"started": flow_started,
		"gameplay_started": gameplay_started,
		"victory": victory_reached,
		"world_completed": world_completed,
		"collectibles": player.get("collected"),
		"medal": player.get("medal_obtained")
	}

# Yuki detecta el punto debil del jefe cuando esta cerca en la fase de nucleo.
func _process(_delta: float) -> void:
	_update_progress_gates()
	if boss == null or yuki == null:
		return
	if boss.has_method("expose_core") and not boss.get("defeated"):
		if yuki.global_position.distance_to(boss.global_position) <= 4.0:
			yuki.call("detect_weakness", boss)

func _on_boss_defeated() -> void:
	print("FLOW_BOSS_DEFEATED Mundo 1 Biobío")
	if hud.has_method("show_message"):
		hud.show_message("¡Jefe derrotado! El Biobío está libre. Toma la medalla.")
	if medal_area.has_method("set_monitoring"):
		medal_area.set_monitoring(true)
	if int(player.get("collected")) < 4 and hud.has_method("show_message"):
		hud.show_message("¡Jefe desactivado! Completa el Diario para liberar la medalla.")

func _configure_expanded_layout() -> void:
	# Cinco segmentos: tutorial, bosque, río, humedal y claro del jefe.
	player.position = Vector3(ROUTE_START_X + 8.0, 1.0, 0.0)
	yuki.position = Vector3(ROUTE_START_X + 4.0, 0.55, -0.8)
	$Kira.position = Vector3(ROUTE_START_X + 2.0, 0.55, 0.8)
	$Chinita.position = Vector3(-315.0, 0.85, 0.0)
	$Abejorro.position = Vector3(-145.0, 0.95, -0.8)
	$Libelula.position = Vector3(35.0, 1.45, 0.7)
	$RanitaPequena.position = Vector3(215.0, 2.55, -0.4)
	$Piedra.position = Vector3(270.0, 0.45, 1.25)
	$Rama.position = Vector3(300.0, 0.65, 0.8)
	robot.position = Vector3(292.0, 0.6, 0.0)
	boss.position = Vector3(390.0, 0.6, 0.0)
	medal_area.position = Vector3(438.0, 1.15, 0.0)
	bike.position = Vector3(-200.0, 0.6, 1.4)

	$JumpPlatform1.position = Vector3(15.0, 1.15, 0.0)
	$JumpPlatform2.position = Vector3(42.0, 2.1, 0.0)
	$RiverVisual.position = Vector3(28.0, 0.26, 0.0)
	$RiverFoamA.position.x = 28.0
	$RiverFoamB.position.x = 28.0

	var ground_mesh := $Ground/GroundMesh.mesh as BoxMesh
	var ground_shape := $Ground/GroundCollision.shape as BoxShape3D
	var under_mesh := $UnderGroundVisual.mesh as BoxMesh
	var sky_mesh := $SkyPanel.mesh as BoxMesh
	ground_mesh.size.x = ROUTE_LENGTH_M + 40.0
	ground_shape.size.x = ROUTE_LENGTH_M + 40.0
	under_mesh.size.x = ROUTE_LENGTH_M + 40.0
	sky_mesh.size.x = ROUTE_LENGTH_M + 80.0

	var camera := $SideCamera
	camera.set("min_x", ROUTE_START_X)
	camera.set("max_x", ROUTE_END_X)

	_create_progress_gates()
	_create_checkpoints()
	_create_route_scenery()

func _create_progress_gates() -> void:
	var gates := Node3D.new()
	gates.name = "ProgressGates"
	add_child(gates)
	for index in GATE_POSITIONS.size():
		var gate := StaticBody3D.new()
		gate.name = "Gate%d" % (index + 1)
		gate.position = Vector3(GATE_POSITIONS[index], 2.0, 0.0)
		gate.set_meta("required_count", index + 1)
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = Vector3(0.8, 4.0, 5.0)
		collision.shape = shape
		gate.add_child(collision)
		var visual := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.35, 4.0, 4.8)
		visual.mesh = mesh
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0.18, 0.55, 0.30, 0.78)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		visual.material_override = material
		gate.add_child(visual)
		var label := Label3D.new()
		label.text = ["Registra la Chinita", "Registra el Abejorro", "Registra la Libélula", "Completa el Diario y desactiva al robot"][index]
		label.position = Vector3(0, 2.7, 0)
		label.font_size = 42
		label.outline_size = 8
		label.modulate = Color(0.92, 1.0, 0.78)
		gate.add_child(label)
		gates.add_child(gate)

func _create_checkpoints() -> void:
	var checkpoints := Node3D.new()
	checkpoints.name = "Checkpoints"
	add_child(checkpoints)
	for index in SEGMENT_CHECKPOINTS.size():
		var checkpoint := Marker3D.new()
		checkpoint.name = "Segment%d" % (index + 1)
		checkpoint.position = Vector3(SEGMENT_CHECKPOINTS[index], 1.0, 0.0)
		var label := Label3D.new()
		label.text = ["1 · Sendero inicial", "2 · Bosque de Yuki", "3 · Río y plataformas", "4 · Humedal de Kira", "5 · Claro del jefe"][index]
		label.position = Vector3(8.0, 3.4, -1.8)
		label.font_size = 48
		label.outline_size = 10
		label.modulate = Color(1.0, 0.86, 0.38)
		checkpoint.add_child(label)
		checkpoints.add_child(checkpoint)

func _create_route_scenery() -> void:
	var scenery := Node3D.new()
	scenery.name = "ExpandedScenery"
	add_child(scenery)
	for index in range(19):
		var x := ROUTE_START_X + 25.0 + index * 48.0
		var trunk := MeshInstance3D.new()
		var trunk_mesh := CylinderMesh.new()
		trunk_mesh.top_radius = 0.22
		trunk_mesh.bottom_radius = 0.32
		trunk_mesh.height = 2.4
		trunk.mesh = trunk_mesh
		trunk.position = Vector3(x, 1.2, -2.2 if index % 2 == 0 else 2.2)
		var trunk_mat := StandardMaterial3D.new()
		trunk_mat.albedo_color = Color(0.30, 0.16, 0.06)
		trunk.material_override = trunk_mat
		scenery.add_child(trunk)
		var crown := MeshInstance3D.new()
		var crown_mesh := SphereMesh.new()
		crown_mesh.radius = 1.25
		crown_mesh.height = 2.5
		crown.mesh = crown_mesh
		crown.position = trunk.position + Vector3(0, 2.0, 0)
		var crown_mat := StandardMaterial3D.new()
		crown_mat.albedo_color = Color(0.10 + float(index % 3) * 0.025, 0.42, 0.19)
		crown.material_override = crown_mat
		scenery.add_child(crown)

func _on_route_progress_changed(_count: int, _total: int) -> void:
	_update_progress_gates()

func _update_progress_gates() -> void:
	var gates := get_node_or_null("ProgressGates")
	if gates == null:
		return
	var collected := int(player.get("collected"))
	for index in gates.get_child_count():
		var gate := gates.get_child(index) as StaticBody3D
		var unlocked := collected >= int(gate.get_meta("required_count"))
		if index == 3:
			# El último gate exige el Diario completo Y el jefe (BossCosmicBeetle) derrotado.
			# El robot básico (EscarabajoRobot) no tiene fases; el flag correcto es `defeated` del jefe.
			unlocked = unlocked and bool(boss.get("defeated"))
		var collision := gate.get_child(0) as CollisionShape3D
		collision.set_deferred("disabled", unlocked)
		gate.visible = not unlocked

func get_route_metrics() -> Dictionary:
	var optimal_traversal_seconds := ROUTE_LENGTH_M / 6.8
	return {
		"segments": SEGMENT_CHECKPOINTS.size(),
		"route_length_m": ROUTE_LENGTH_M,
		"gates": GATE_POSITIONS.size(),
		"optimal_traversal_seconds": optimal_traversal_seconds,
		"interaction_seconds": OPTIMAL_INTERACTION_SECONDS,
		"optimal_seconds": optimal_traversal_seconds + OPTIMAL_INTERACTION_SECONDS,
	}

# Optional: handle input for quicksave/quickload (F5/F9) for testing
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			_on_save_requested()
		elif event.keycode == KEY_F9:
			_on_load_requested()
