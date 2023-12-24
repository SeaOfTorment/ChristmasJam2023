extends Control

@onready var player_vars = get_node("/root/PlayerVariables")

@export var player : CharacterBody3D
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func show_death():
	show()
	$MarginContainer/VBoxContainer/Label2.text = "Death Count: " + str(player_vars.death_count)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func respawn():
	hide()
	player.respawn()


func exit():
	get_tree().quit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
