extends Node

@onready var passives = $"../passives"
@onready var ui = $"../../CanvasLayer/VBoxContainer/HBoxContainer"
@onready var ui_hp = $"../../CanvasLayer/VBoxContainer/HBoxContainer/hub/HP"
@onready var ui_hp_prog = $"../../CanvasLayer/VBoxContainer/HBoxContainer/hub/HP_PROG"
@onready var ui_debug_stats = $"../../CanvasLayer/VBoxContainer/HBoxContainer/debug/stats"
@export var base_ms: float = 1.0
@export var base_as: float = 1.0
@export var weapon_dmg: float = 1.0
@export var base_hp: float = 100
@export var base_heal_rate: float = 0
var debug_stat_boiler = "
STAT: BASE + PASSIVE
DM: %s + %s
HP: %s + %s
MS: %s + %s
AS: %s + %s
HR: %s + %s"

var current_hp: float = base_hp

func _ready():
	ui_hp.text = str(current_hp)
	
	
func _process(_delta):
	ui_hp.text = str(current_hp)
	ui_hp_prog.value = current_hp
	ui_hp_prog.max_value = base_hp + passives.bonus_health
	ui_debug_stats.text = (debug_stat_boiler % [weapon_dmg, passives.damage, base_hp, passives.bonus_health, base_ms, passives.movement_speed, base_as, passives.attack_speed, base_heal_rate, passives.heal_rate] )
