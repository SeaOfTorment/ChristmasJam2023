extends Node3D

signal hitbox(body)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_attack_hitbox_body_entered(body):
	hitbox.emit(body)
