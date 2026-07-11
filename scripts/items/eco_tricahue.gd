extends Area3D
class_name EcoTricahue

@export var label := "Eco de tricahue"
@export_multiline var diary_text := "Grito resonante del loro tricahue, revela caminos ocultos en quebradas."
var used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("echo_reveal")

func interact(player: Node) -> void:
	if used:
		return
	used = true
	visible = false
	set_deferred("monitoring", false)
	print("MECÁNICA: %s — %s" % [label, diary_text])
	if player.has_method("activate_echo_reveal"):
		player.activate_echo_reveal(10.0)

func _on_body_entered(body: Node) -> void:
	if used:
		return
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self)