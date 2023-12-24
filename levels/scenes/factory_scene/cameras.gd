extends MeshInstance3D

@onready var cam = $"../../../Player/CameraMount"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if cam and is_instance_valid(cam):
		look_at(cam.global_position)
