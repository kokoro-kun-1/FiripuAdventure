extends Node3D

@onready var player: Node = $Firipu
@onready var hud: Node = $HUD
@onready var medal_area: Area3D = $MedalArea
@onready var robot: Node = $EscarabajoRobot

var flow_started := false
var victory_reached := false
var gameplay_started := false
# Reference to savegame singleton
var save_game : Node

func _ready() -> void:

	if hud.has_method("bind_player"):
		hud.bind_player(player)
		if hud.has_signal("start_requested"):
			hud.start_requested.connect(_on_start_requested)
		if player.has_method("set_input_locked"):
			player.set_input_locked(true)
		medal_area.body_entered.connect(_on_medal_area_body_entered)
		if player.has_signal("prototype_completed"):
			player.prototype_completed.connect(_on_prototype_completed)
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

func _on_medal_area_body_entered(body: Node) -> void:
	if body == player and player.has_method("obtain_medal"):
		player.obtain_medal()

func _on_prototype_completed() -> void:
	victory_reached = true
	if hud.has_method("show_victory"):
		hud.show_victory()
	print("FLOW_VICTORY Mundo 1 Biobío")
	
	# Autosave when world completed
	if save_game != null:
		save_game.save_game(self)
		# Optionally show a message
		if hud.has_method("show_message"):
			hud.show_message("Partida guardada.")

func get_flow_status() -> Dictionary:
	return {
		"started": flow_started,
		"gameplay_started": gameplay_started,
		"victory": victory_reached,
		"collectibles": player.get("collected"),
		"medal": player.get("medal_obtained")
	}

# Optional: handle input for quicksave/quickload (F5/F9) for testing
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_F5:  # F5 quicksave
			if save_game != null:
				save_game.save_game(self)
				if hud.has_method("show_message"):
					hud.show_message("Partida guardada (F5).")
		elif event.scancode == KEY_F9:  # F9 quickload
			if save_game != null:
				save_game.load_game(self)
				if hud.has_method("show_message"):
					hud.show_message("Partida cargada (F9).")