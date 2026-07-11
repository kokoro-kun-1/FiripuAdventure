extends Area3D
class_name SteamVent

# Chorro de vapor termal de Ñuble: eleva a quien entra, como ascensor temporal.

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
    if body.has_method("set_in_steam"):
        body.set_in_steam(true)

func _on_body_exited(body: Node) -> void:
    if body.has_method("set_in_steam"):
        body.set_in_steam(false)
