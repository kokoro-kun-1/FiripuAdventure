extends Area3D
class_name BotasHielo

@export var label := "Botas de hielo antideslizantes"
@export_multiline var diary_text := "Calzado especial con crampones integrados, permite caminar sobre hielo sin resbalar."
var used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("ice_boots")

func interact(player: Node) -> void:
	if used:
		return
	used = true
	visible = false
	set_deferred("monitoring", false)
	print("MECÁNICA: %s — %s" % [label, diary_text])
	if player.has_method("activate_ice_boots"):
		player.activate_ice_boots(15.0)

func _on_body_entered(body: Node) -> void:
	if used:
		return
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self)