extends Area3D
class_name HojaParaguas

@export var label := "Hoja paraguas"
@export_multiline var diary_text := "Hoja gigante de nalca, permite planear suavemente bajo la lluvia."
var used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("glide_boost")

func interact(player: Node) -> void:
	if used:
		return
	used = true
	visible = false
	set_deferred("monitoring", false)
	print("MECÁNICA: %s — %s" % [label, diary_text])
	if player.has_method("activate_glide_boost"):
		player.activate_glide_boost(10.0)

func _on_body_entered(body: Node) -> void:
	if used:
		return
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self)