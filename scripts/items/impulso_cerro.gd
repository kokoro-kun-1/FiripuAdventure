extends Area3D
class_name ImpulsoCerro

@export var label := "Impulso de cerro"
@export_multiline var diary_text := "Brisa descendente de la precordillera, acelera descensos controlados."
var used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("hill_boost")

func interact(player: Node) -> void:
	if used:
		return
	used = true
	visible = false
	set_deferred("monitoring", false)
	print("MECÁNICA: %s — %s" % [label, diary_text])
	if player.has_method("activate_hill_boost"):
		player.activate_hill_boost(8.0)

func _on_body_entered(body: Node) -> void:
	if used:
		return
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self)