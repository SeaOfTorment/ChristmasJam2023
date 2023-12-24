extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func hit(_damage, direction, _source): #underscored to prevent error on unused var

	apply_central_impulse(direction * 9)
