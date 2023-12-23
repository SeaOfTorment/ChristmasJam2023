extends MeshInstance3D

@onready var cam = $"../../../Player/CameraMount/SpringArm3D/Camera3D"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if cam:
		look_at(cam.get_parent().get_parent().global_position)
