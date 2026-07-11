extends Area3D
class_name CamanchacaReveladora

@export var label := "Camanchaca reveladora"
@export_multiline var diary_text := "Niebla costera densa que revela plataformas ocultas al condensarse."
var used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("camanchaca")

func interact(player: Node) -> void:
	if used:
		return
	used = true
	visible = false
	set_deferred("monitoring", false)
	print("MECÁNICA: %s — %s" % [label, diary_text])
	if player.has_method("activate_camanchaca"):
		player.activate_camanchaca(12.0)

func _on_body_entered(body: Node) -> void:
	if used:
		return
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self)