extends Area3D
class_name Collectible

@export var label := "Coleccionable"
@export_multiline var diary_text := "Entrada del Diario de Naturaleza."
var registered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# Add to group for saving/loading
	add_to_group("collectible")

func interact(player: Node) -> void:
	if registered:
		return
	registered = true
	visible = false
	set_deferred("monitoring", false)
	print("Diario: %s — %s" % [label, diary_text])
	if player.has_method("register_collectible"):
		player.register_collectible(label)

func _on_body_entered(body: Node) -> void:
	if registered:
		return
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self)

func _on_body_exited(body: Node) -> void:
	if body.has_method("clear_nearby_interactable"):
		body.clear_nearby_interactable(self)