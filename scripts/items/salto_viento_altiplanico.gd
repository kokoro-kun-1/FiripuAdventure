extends Area3D
class_name SaltoVientoAltiplanico

@export var label := "Salto viento altiplánico"
@export_multiline var diary_text := "Corriente ascendente de altura, impulsa saltos largos entre plataformas de roca."
var used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("altiplano_wind")

func interact(player: Node) -> void:
	if used:
		return
	used = true
	visible = false
	set_deferred("monitoring", false)
	print("MECÁNICA: %s — %s" % [label, diary_text])
	if player.has_method("activate_altiplano_wind"):
		player.activate_altiplano_wind(12.0)

func _on_body_entered(body: Node) -> void:
	if used:
		return
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self)