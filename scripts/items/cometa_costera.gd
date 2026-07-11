extends Area3D
class_name CometaCostera

@export var label := "Cometa costera"
@export_multiline var diary_text := "Cometa de papel reforzada, permite planear sobre viento costero entre cerros."
var used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("kite_glide")

func interact(player: Node) -> void:
	if used:
		return
	used = true
	visible = false
	set_deferred("monitoring", false)
	print("MECÁNICA: %s — %s" % [label, diary_text])
	if player.has_method("activate_kite_glide"):
		player.activate_kite_glide(12.0)

func _on_body_entered(body: Node) -> void:
	if used:
		return
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self)