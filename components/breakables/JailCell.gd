extends Node3D


@export var health = 10

var door_is_broken = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$NotBrokenDoor.visible = true
	$Door.visible = false



func break_door():
	door_is_broken = true
	$NotBrokenDoor.visible = false
	$Door.visible = true
	
	$Door/AnimationPlayer.play("Key_001Action")
	$CollisionShape3D.set_deferred("disabled", true)
	await get_tree().create_timer(3).timeout
	queue_free()


func hit(damage, direction, source):
	print("breaking!!!")
	
	health -= damage
	
	if health <= 0:
		break_door()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
