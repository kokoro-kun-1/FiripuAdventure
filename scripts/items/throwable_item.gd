extends Area3D
class_name ThrowableItem

@export var label := "Piedra"
var picked := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func interact(player: Node) -> void:
	if picked:
		return
	picked = true
	visible = false
	set_deferred("monitoring", false)
	if player.has_method("pick_environment_object"):
		player.pick_environment_object(label)

func _on_body_entered(body: Node) -> void:
	if not picked and body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self)

func _on_body_exited(body: Node) -> void:
	if body.has_method("clear_nearby_interactable"):
		body.clear_nearby_interactable(self)
