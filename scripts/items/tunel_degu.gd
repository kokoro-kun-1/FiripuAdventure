extends Area3D
class_name TunelDegu

@export var label := "Túnel de degú"
@export_multiline var diary_text := "Madriguera de degú, permite atajos subterráneos entre matorrales."
var used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("tunnel_shortcut")

func interact(player: Node) -> void:
	if used:
		return
	used = true
	visible = false
	set_deferred("monitoring", false)
	print("MECÁNICA: %s — %s" % [label, diary_text])
	if player.has_method("activate_degu_tunnel"):
		player.activate_degu_tunnel(10.0)

func _on_body_entered(body: Node) -> void:
	if used:
		return
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self)