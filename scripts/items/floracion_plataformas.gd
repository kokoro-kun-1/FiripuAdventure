extends Area3D
class_name FloracionPlataformas

@export var label := "Floración temporal"
@export_multiline var diary_text := "Flores del desierto que emergen tras lluvia, forman plataformas efímeras."
var used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("bloom_platform")

func interact(player: Node) -> void:
	if used:
		return
	used = true
	visible = false
	set_deferred("monitoring", false)
	print("MECÁNICA: %s — %s" % [label, diary_text])
	if player.has_method("activate_bloom_platforms"):
		player.activate_bloom_platforms(15.0)

func _on_body_entered(body: Node) -> void:
	if used:
		return
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self)