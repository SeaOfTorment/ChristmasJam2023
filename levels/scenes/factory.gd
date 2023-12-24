extends Node3D

var red_gift = preload("res://levels/scenes/factory_scene/prefabs/red_present.tscn")
var green_gift = preload("res://levels/scenes/factory_scene/prefabs/green_present.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var arr = [red_gift, green_gift]
	var markers = $boxes_pawn_points.get_children()
	while(true):
		var rng = RandomNumberGenerator.new()
		var gift_inst = arr[rng.randf_range(0, 2)].instantiate()
		$gift_boxes.add_child(gift_inst)
		rng = RandomNumberGenerator.new()
		gift_inst.position = markers[rng.randf_range(0, 6)].position
		await get_tree().create_timer(0.35).timeout


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
