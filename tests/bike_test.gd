extends SceneTree

var _t := 0.0
var _phase := 0
var _firipu: Node = null
var _bike: Node = null

func _initialize() -> void:
    var scene: PackedScene = load("res://scenes/levels/level_biobio_prototype.tscn")
    var level: Node = scene.instantiate()
    root.add_child(level)
    _firipu = level.get_node_or_null("Firipu")
    _bike = level.get_node_or_null("Bike")
    if _firipu == null or _bike == null:
        print("BIKE_TEST: FAIL faltan nodos firipu/bike")
        quit(1)
        return
    if not _firipu.has_method("mount_bike"):
        print("BIKE_TEST: FAIL firipu no tiene mount_bike")
        quit(1)
        return

func _process(delta: float) -> bool:
    _t += delta
    if _phase == 0:
        # mount bike immediately
        _bike.call("interact", _firipu)
        _phase = 1
    elif _phase == 1:
        if not _firipu.get("bike_boost_active"):
            print("BIKE_TEST: FAIL boost no activo tras interact")
            quit(1)
            return false
        if _bike.visible:
            print("BIKE_TEST: FAIL bike no se oculto")
            quit(1)
            return false
        # re-mount with short duration to test expiry
        _firipu.call("dismount_bike")
        _firipu.call("mount_bike", 0.2)
        _phase = 2
        _t = 0.0
    elif _phase == 2:
        if _t >= 0.4:
            if _firipu.get("bike_boost_active"):
                print("BIKE_TEST: FAIL boost no expiro")
                quit(1)
                return false
            print("BIKE_TEST: PASS")
            quit(0)
            return false
    return false
