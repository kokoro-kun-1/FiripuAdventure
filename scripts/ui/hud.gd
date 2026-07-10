extends CanvasLayer

signal start_requested

@onready var fauna_label: Label = $Panel/VBox/FaunaLabel
@onready var object_label: Label = $Panel/VBox/ObjectLabel
@onready var medal_label: Label = $Panel/VBox/MedalLabel
@onready var state_label: Label = $Panel/VBox/StateLabel
@onready var controls_label: Label = $Panel/VBox/ControlsLabel
@onready var hint_label: Label = $BottomPanel/HintLabel
@onready var start_panel: Panel = $StartPanel
@onready var start_label: Label = $StartPanel/StartLabel
@onready var victory_panel: Panel = $VictoryPanel
@onready var victory_label: Label = $VictoryPanel/VictoryLabel

var game_started := false
var latest_count := 0
var latest_total := 4
var latest_object := "Ninguno"
var latest_medal := "Medalla: Pendiente"

func _ready() -> void:
	_ensure_xbox_start_action()
	victory_panel.visible = false
	start_panel.visible = true
	start_label.text = "Firipu Adventure\nMundo 1: Biobío Silvestre\n\nObjetivo:\nRegistre 4 especies, use un objeto contra el robot\ny recupere la Medalla del Bosque y Río.\n\nEnter / botón A para comenzar"
	controls_label.text = "Xbox: Stick izq. mover · A saltar/aceptar · X interactuar · RB usar objeto · B esquivar · LB/RT correr | Teclado: A/D/W/S · Espacio · E · Click"
	show_message("Presione Enter o botón A del mando Xbox para comenzar la aventura.")

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

func show_message(text: String) -> void:
	hint_label.text = text

func show_victory() -> void:
	var fauna_summary := "Fauna registrada: %d/%d" % [latest_count, latest_total]
	victory_label.text = "¡Mundo 1 completado!\n\n%s\nObjeto final: %s\n%s\n\nMedalla del Bosque y Río del Biobío conseguida.\n\nGracias por probar el prototipo 0.1." % [fauna_summary, latest_object, latest_medal]
	victory_panel.visible = true

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
