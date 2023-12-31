extends Area3D

@export var cap = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var bodies = get_overlapping_bodies()
	var dv = transform.basis * Vector3(-1,0,0)
	for i in bodies:
		if i is RigidBody3D:
			i.linear_velocity = dv * 0.06
			i.angular_velocity = Vector3(0, 0, 0)
			#i.apply_central_impulse(dv * 0.01)
		
	get_overlapping_bodies()
