extends CanvasLayer

signal done

@export var player : CharacterBody3D

@export var npc_name : String
@export var text_lines : Array[String]

# Called when the node enters the scene tree for the first time.

func _ready():
	print(player)
	player.being_controlled = true
	
	$TextBox.display_text(npc_name, text_lines)
	
	pass # Replace with function body.


func finished():
	player.being_controlled = false
	done.emit()
