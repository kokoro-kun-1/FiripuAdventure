extends Area3D
class_name BalsaNatural

@export var label := "Balsa natural"
@export_multiline var diary_text := "Troncos entrelazados que flotan, permiten cruzar lagos y ríos."
var used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("raft")

func interact(player: Node) -> void:
	if used:
		return
	used = true
	visible = false
	set_deferred("monitoring", false)
	print("MECÁNICA: %s — %s" % [label, diary_text])
	if player.has_method("activate_raft"):
		player.activate_raft(15.0)

func _on_body_entered(body: Node) -> void:
	if used:
		return
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self)