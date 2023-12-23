extends VBoxContainer

@export var passives : Node
@export var stats: Node
@export var player: CharacterBody3D
@onready var ui = $"HBoxContainer"
@onready var ui_hp = $"HBoxContainer/hub/HP"
@onready var ui_hp_prog = $"HBoxContainer/hub/HP_PROG"
@onready var ui_debug_stats = $"HBoxContainer/debug/stats"
var debug_stat_boiler = "
DM: %s + %s
HP: %s + %s
MS: %s + %s
AS: %s + %s
HR: %s + %s"

func _ready():
	ui_hp.text = str(player.hp)
	
	
func _process(_delta):
	ui_hp.text = str(player.hp) + " / " + str(stats.base_hp + passives.bonus_health)
	ui_hp_prog.value = player.hp
	ui_hp_prog.max_value = stats.base_hp + passives.bonus_health
	ui_debug_stats.text = (
		debug_stat_boiler % [
			stats.weapon_dmg, 
			passives.damage, 
			stats.base_hp, 
			passives.bonus_health, 
			stats.base_ms,
			passives.movement_speed, 
			stats.base_as, 
			passives.attack_speed, 
			stats.base_heal_rate, 
			passives.heal_rate
			]
		)


func _on_check_button_toggled(toggled_on):
	pass # Replace with function body.
