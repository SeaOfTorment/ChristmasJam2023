extends Control

@onready var player_vars = get_node("/root/PlayerVariables")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$GoldCount.text = str(player_vars.gold)
	$KillCount.text = str(player_vars.kill_count)
	pass
