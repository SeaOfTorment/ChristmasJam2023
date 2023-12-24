extends VBoxContainer

@export var player: CharacterBody3D

@onready var player_vars = get_node("/root/PlayerVariables")
@onready var ui = $"HBoxContainer"
@onready var ui_hp = $"HBoxContainer/hub/HP"
@onready var ui_hp_prog = $"HBoxContainer/hub/HP_PROG"
@onready var ui_debug_stats = $"HBoxContainer/debug/stats"
var debug_stat_boiler = "
DM: %s x %s
HP: %s x %s
MS: %s x %s
AS: %s x %s
HR: %s x %s"

func _ready():
	ui_hp.text = str(player.hp)


func _process(_delta):
	ui_hp.text = str(player.hp) + " / " + str(player.max_health)
	ui_hp_prog.value = player.hp
	ui_hp_prog.max_value = player.max_health
	ui_debug_stats.text = (
		debug_stat_boiler % [
			player_vars.base_attack, 
			player_vars.bonus_attack, 
			player_vars.base_health, 
			player_vars.bonus_health, 
			player_vars.base_movement, 
			player_vars.bonus_movement, 
			player_vars.base_attack_speed, 
			player_vars.bonus_attack_speed, 
			player_vars.base_heal_rate, 
			player_vars.bonus_heal_rate, 
			]
		)
