extends Area3D
class_name ImpulsoViento

@export var label := "Impulso de viento patagónico"
@export_multiline var diary_text := "Ráfaga constante del oeste, impulsa saltos y permite cruzar grandes distancias."
var used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("wind_boost")

func interact(player: Node) -> void:
	if used:
		return
	used = true
	visible = false
	set_deferred("monitoring", false)
	print("MECÁNICA: %s — %s" % [label, diary_text])
	if player.has_method("activate_wind_boost"):
		player.activate_wind_boost(12.0)

func _on_body_entered(body: Node) -> void:
	if used:
		return
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self)