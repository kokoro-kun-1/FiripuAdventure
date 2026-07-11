extends Area3D
class_name CristalAntiespejismo

@export var label := "Cristal anti-espejismo"
@export_multiline var diary_text := "Cristal de yeso que filtra la luz, disipa ilusiones de calor."
var used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("crystal_antiespejismo")

func interact(player: Node) -> void:
	if used:
		return
	used = true
	visible = false
	set_deferred("monitoring", false)
	print("MECÁNICA: %s — %s" % [label, diary_text])
	if player.has_method("activate_crystal"):
		player.activate_crystal(10.0)

func _on_body_entered(body: Node) -> void:
	if used:
		return
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self)