extends Node3D


@export var health = 10

var door_is_broken = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$NotBrokenDoor.visible = true
	$Door.visible = false


func on_interaction(_source):
	$CanvasLayer/TextBox.display_text("Jail Wall", ["It seems to be breakable... (It has " + str(health) + " health)"])


func get_interaction_text():
	return "look at door"


func can_interact():
	return not door_is_broken


func break_door():
	door_is_broken = true
	$NotBrokenDoor.visible = false
	$Door.visible = true
	
	$Door/AnimationPlayer.play("Key_001Action")
	$CollisionShape3D.set_deferred("disabled", true)
	await get_tree().create_timer(3).timeout
	queue_free()


func hit(damage, _direction, _source):
	print("breaking!!!")
	
	health -= damage
	
	if health <= 0:
		break_door()
	pass
