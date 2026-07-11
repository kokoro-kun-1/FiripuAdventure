extends Area3D
class_name Bike

@export var label := "Bicicleta de montaña"
@export var boost_duration := 6.0
var used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("bike")

func interact(player: Node) -> void:
	if used:
		return
	used = true
	visible = false
	set_deferred("monitoring", false)
	print("BICICLETA: Firipu monta la bicicleta de montaña")
	if player.has_method("mount_bike"):
		player.mount_bike(boost_duration)

func _on_body_entered(body: Node) -> void:
	if used:
		return
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self)
