extends Node3D

# Mundo 14 — Antofagasta: Camanchaca de Antofagasta.
# Mecánica: camanchaca reveladora (niebla revela plataformas).

@onready var player: Node = $Firipu
@onready var hud: Node = $HUD
@onready var medal_area: Area3D = $MedalArea
@onready var boss: Node = $EscarabajoCobreRobot
@onready var yuki: Node = $Yuki

var flow_started := false
var victory_reached := false
var gameplay_started := false
var world_completed := false
var save_game: Node

func _ready() -> void:
	if hud.has_method("bind_player"):
		hud.bind_player(player)
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
		if player.has_signal("collected_changed"):
			player.collected_changed.connect(_on_route_progress_changed)
		if player.has_signal("prototype_completed"):
			player.prototype_completed.connect(_on_prototype_completed)
	if boss != null and boss.has_signal("boss_defeated"):
		boss.boss_defeated.connect(_on_boss_defeated)
	_start_world_flow()
	print("Firipu Adventure — Antofagasta: Camanchaca iniciado")

	var root = get_tree().root
	if root.has_node("SaveGame"):
		save_game = root.get_node("SaveGame")
	else:
		push_error("SaveGame autoload not found!")

func _start_world_flow() -> void:
	flow_started = true
	if hud.has_method("show_message"):
		hud.show_message("Antofagasta: usa camanchaca reveladora, registra 4 especies y enfrenta al Escarabajo Cobre Robot.")
	print("FLOW_START Mundo 14 Antofagasta")

func _on_start_requested() -> void:
	gameplay_started = true
	if player.has_method("set_input_locked"):
		player.set_input_locked(false)
	print("FLOW_GAMEPLAY_START Mundo 14 Antofagasta")

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
	print("FLOW_EXIT_REQUESTED Mundo 14 Antofagasta")
	get_tree().quit(0)

func _on_medal_area_body_entered(body: Node) -> void:
	if body == player and int(player.get("collected")) >= 4 and bool(boss.get("defeated")) and player.has_method("obtain_medal"):
		player.obtain_medal()
	elif body == player and hud.has_method("show_message"):
		hud.show_message("La medalla se libera al completar el Diario y calmar al guardian.")


func _on_prototype_completed() -> void:
	set_world_completed(true)
	var global_progress := get_node_or_null("/root/GlobalProgress")
	if global_progress != null:
		global_progress.complete_world("antofagasta")
		global_progress.force_save()
	print("FLOW_VICTORY Mundo 14 Antofagasta")
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

func _process(_delta: float) -> void:
	if boss == null or yuki == null:
		return
	if boss.has_method("expose_core") and not boss.get("defeated"):
		if yuki.global_position.distance_to(boss.global_position) <= 4.0:
			yuki.call("detect_weakness", boss)

func _on_boss_defeated() -> void:
	print("FLOW_BOSS_DEFEATED Mundo 14 Antofagasta")
	if hud.has_method("show_message"):
		hud.show_message("¡Escarabajo Cobre Robot reparado! La camanchaca se disipa. Toma la medalla.")
	if medal_area.has_method("set_monitoring"):
		medal_area.set_monitoring(true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			_on_save_requested()
		elif event.keycode == KEY_F9:
			_on_load_requested()

func _on_route_progress_changed(_count: int, _total: int) -> void:
	pass
