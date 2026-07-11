extends Area3D
class_name TroncoFlotante

@export var label := "Tronco flotante"
@export_multiline var diary_text := "Tronco hueco que flota río abajo, sirve de balsa temporal."
var used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("raft_log")

func interact(player: Node) -> void:
	if used:
		return
	used = true
	visible = false
	set_deferred("monitoring", false)
	print("MECÁNICA: %s — %s" % [label, diary_text])
	if player.has_method("activate_raft_log"):
		player.activate_raft_log(12.0)

func _on_body_entered(body: Node) -> void:
	if used:
		return
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self)