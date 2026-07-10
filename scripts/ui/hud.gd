extends CanvasLayer

signal start_requested
signal save_requested
signal load_requested
signal exit_requested

@onready var fauna_label: Label = $Panel/VBox/FaunaLabel
@onready var object_label: Label = $Panel/VBox/ObjectLabel
@onready var medal_label: Label = $Panel/VBox/MedalLabel
@onready var state_label: Label = $Panel/VBox/StateLabel
@onready var controls_label: Label = $Panel/VBox/ControlsLabel
@onready var save_button: Button = $Panel/VBox/SaveLoadButtons/SaveButton
@onready var load_button: Button = $Panel/VBox/SaveLoadButtons/LoadButton
@onready var hint_label: Label = $BottomPanel/HintLabel
@onready var start_panel: Panel = $StartPanel
@onready var start_label: Label = $StartPanel/StartLabel
@onready var pause_panel: Panel = $PausePanel
@onready var pause_continue_button: Button = $PausePanel/PauseVBox/ContinueButton
@onready var pause_save_button: Button = $PausePanel/PauseVBox/SaveButton
@onready var pause_load_button: Button = $PausePanel/PauseVBox/LoadButton
@onready var pause_exit_button: Button = $PausePanel/PauseVBox/ExitButton
@onready var victory_panel: Panel = $VictoryPanel
@onready var victory_title_label: Label = $VictoryPanel/VictoryVBox/VictoryTitleLabel
@onready var victory_summary_label: Label = $VictoryPanel/VictoryVBox/VictorySummaryLabel
@onready var victory_next_label: Label = $VictoryPanel/VictoryVBox/VictoryNextLabel
@onready var victory_continue_button: Button = $VictoryPanel/VictoryVBox/VictoryButtons/ContinueButton
@onready var victory_save_button: Button = $VictoryPanel/VictoryVBox/VictoryButtons/SaveButton
@onready var victory_exit_button: Button = $VictoryPanel/VictoryVBox/VictoryButtons/ExitButton

var game_started := false
var pause_open := false
var latest_count := 0
var latest_total := 4
var latest_object := "Ninguno"
var latest_medal := "Medalla: Pendiente"
var pause_exit_pending := false
var victory_exit_pending := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_ui_actions()
	save_button.pressed.connect(_on_save_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	pause_continue_button.pressed.connect(close_pause_menu)
	pause_save_button.pressed.connect(_on_pause_save_button_pressed)
	pause_load_button.pressed.connect(_on_pause_load_button_pressed)
	pause_exit_button.pressed.connect(_on_pause_exit_button_pressed)
	victory_continue_button.pressed.connect(_on_victory_continue_button_pressed)
	victory_save_button.pressed.connect(_on_victory_save_button_pressed)
	victory_exit_button.pressed.connect(_on_victory_exit_button_pressed)
	victory_panel.visible = false
	pause_panel.visible = false
	start_panel.visible = true
	start_label.text = "Firipu Adventure\nMundo 1: Biobío Silvestre\n\nObjetivo:\nRegistre 4 especies, use un objeto contra el robot\ny recupere la Medalla del Bosque y Río.\n\nEnter / botón A para comenzar\nF5 guardar · F9 cargar · Esc pausa"
	controls_label.text = "Controles: A/D/W/S mover · Espacio saltar · E interactuar · Click usar objeto · F5 guardar · F9 cargar · Esc pausa"
	show_message("Presione Enter o botón A del mando Xbox para comenzar la aventura.")

func _ensure_ui_actions() -> void:
	_ensure_xbox_start_action()
	if not InputMap.has_action("pause_menu"):
		InputMap.add_action("pause_menu")
	var esc_event := InputEventKey.new()
	esc_event.keycode = KEY_ESCAPE
	InputMap.action_add_event("pause_menu", esc_event)
	var start_event := InputEventJoypadButton.new()
	start_event.button_index = JOY_BUTTON_START
	InputMap.action_add_event("pause_menu", start_event)

func _ensure_xbox_start_action() -> void:
	if not InputMap.has_action("ui_accept"):
		InputMap.add_action("ui_accept")
	var accept_event := InputEventJoypadButton.new()
	accept_event.button_index = JOY_BUTTON_A
	InputMap.action_add_event("ui_accept", accept_event)
	var start_event := InputEventJoypadButton.new()
	start_event.button_index = JOY_BUTTON_START
	InputMap.action_add_event("ui_accept", start_event)

func _unhandled_input(event: InputEvent) -> void:
	if not game_started and event.is_action_pressed("ui_accept"):
		start_game()
		return
	if game_started and event.is_action_pressed("pause_menu"):
		toggle_pause_menu()

func bind_player(player: Node) -> void:
	if player.has_signal("collected_changed"):
		player.collected_changed.connect(_on_collected_changed)
	if player.has_signal("object_changed"):
		player.object_changed.connect(_on_object_changed)
	if player.has_signal("medal_state_changed"):
		player.medal_state_changed.connect(_on_medal_state_changed)
	if player.has_signal("action_hint_changed"):
		player.action_hint_changed.connect(show_message)
	if player.has_signal("movement_state_changed"):
		player.movement_state_changed.connect(_on_movement_state_changed)
	if player.has_signal("prototype_completed"):
		player.prototype_completed.connect(show_victory)

func start_game() -> void:
	if game_started:
		return
	game_started = true
	start_panel.visible = false
	show_message("Avance por el sendero: registre la fauna, tome piedra/rama y enfrente al robot.")
	start_requested.emit()

func toggle_pause_menu() -> void:
	if pause_open:
		close_pause_menu()
	else:
		open_pause_menu()

func open_pause_menu() -> void:
	if pause_open:
		return
	pause_open = true
	_reset_exit_confirmations()
	pause_panel.visible = true
	get_tree().paused = true
	pause_continue_button.grab_focus()
	show_message("Pausa: puede guardar, cargar, continuar o salir.")

func close_pause_menu() -> void:
	if not pause_open:
		return
	pause_open = false
	_reset_exit_confirmations()
	pause_panel.visible = false
	get_tree().paused = false
	show_message("Juego reanudado.")

func is_pause_menu_open() -> bool:
	return pause_open

func show_message(text: String) -> void:
	hint_label.text = text

func _on_save_button_pressed() -> void:
	show_message("Guardando partida...")
	save_requested.emit()

func _on_load_button_pressed() -> void:
	show_message("Cargando partida...")
	load_requested.emit()

func _on_pause_save_button_pressed() -> void:
	_reset_exit_confirmations()
	show_message("Guardando desde pausa...")
	save_requested.emit()

func _on_pause_load_button_pressed() -> void:
	_reset_exit_confirmations()
	show_message("Cargando desde pausa...")
	load_requested.emit()

func _on_pause_exit_button_pressed() -> void:
	if not pause_exit_pending:
		pause_exit_pending = true
		victory_exit_pending = false
		pause_exit_button.text = "Confirmar salida"
		victory_exit_button.text = "Salir"
		show_message("Presione Confirmar salida para cerrar el prototipo sin guardar cambios nuevos.")
		return
	show_message("Saliendo del prototipo...")
	get_tree().paused = false
	exit_requested.emit()

func show_victory() -> void:
	victory_title_label.text = "¡Mundo 1 completado!"
	victory_summary_label.text = get_victory_summary()
	victory_next_label.text = "Siguiente paso: en una futura versión se desbloqueará la próxima región de Chile.\nPuede seguir explorando, guardar la partida o salir del prototipo."
	victory_panel.visible = true
	victory_continue_button.grab_focus()

func get_victory_summary() -> String:
	var object_text := latest_object
	if object_text.strip_edges() == "" or object_text == "Ninguno":
		object_text = "Sin objeto equipado al cierre"
	return "Resumen de aventura\n• Diario de Naturaleza: %d/%d especies registradas\n• Objeto final: %s\n• Estado de medalla: %s\n• Región protegida: Biobío Silvestre\n• Prototipo: 0.1" % [latest_count, latest_total, object_text, latest_medal]

func _on_victory_continue_button_pressed() -> void:
	_reset_exit_confirmations()
	victory_panel.visible = false
	show_message("Puede seguir explorando el Biobío o guardar la partida con F5.")

func _on_victory_save_button_pressed() -> void:
	_reset_exit_confirmations()
	show_message("Guardando victoria...")
	save_requested.emit()

func _on_victory_exit_button_pressed() -> void:
	if not victory_exit_pending:
		victory_exit_pending = true
		pause_exit_pending = false
		victory_exit_button.text = "Confirmar salida"
		pause_exit_button.text = "Salir del prototipo"
		show_message("Presione Confirmar salida para cerrar el prototipo. Use Guardar victoria si desea conservar el avance.")
		return
	show_message("Saliendo del prototipo...")
	get_tree().paused = false
	exit_requested.emit()

func _reset_exit_confirmations() -> void:
	pause_exit_pending = false
	victory_exit_pending = false
	pause_exit_button.text = "Salir del prototipo"
	victory_exit_button.text = "Salir"

func _on_collected_changed(count: int, total: int) -> void:
	latest_count = count
	latest_total = total
	fauna_label.text = "Diario de Naturaleza: %d/%d" % [count, total]

func _on_object_changed(text: String) -> void:
	latest_object = text
	object_label.text = "Objeto: %s" % text

func _on_medal_state_changed(text: String) -> void:
	latest_medal = text
	medal_label.text = text

func _on_movement_state_changed(text: String) -> void:
	state_label.text = "Firipu: %s" % text
