extends Node3D


@export_enum("BlackSmithElf", "CookElf", "EmoElf", "EnchanterElf", "FriendlyElf", "RebelElf", "Reindeer", "SantaElf", "Yeti") var model
# Called when the node enters the scene tree for the first time.

func _ready():
	if model == null:
		return
	
	cull_models()


func cull_models():
	var node = $rig_deform/Skeleton3D
	var list = node.get_children()
	for n in list.size():
		var m = list[n]
		if n != model:
			node.remove_child(m)
			m.queue_free()
