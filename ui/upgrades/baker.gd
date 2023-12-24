extends Control



const WEAPON_TYPE = [
	{
		"name": "Candy Cane",
		"damage": 1,
		"movement_speed": 1.1,
		"attack_speed": 1.1,
		"bonus_health": 0,
		"heal_rate": 0
	},
	{
		"name": "Candy Cane",
		"damage": 5,
		"movement_speed": 1.1,
		"attack_speed": 1.1,
		"bonus_health": 0,
		"heal_rate": 0
	}
]

const DESCRIPTORS = {
	"damage": ["Weak", "Smack", "Hard Hitting", "Ultra Bonk"],
	"movement_speed": ["Slow Walking", "Joggers", "Speedster"],
	"attack_speed": ["Grandma Swing", "Golfer", "Fast"],
	"bonus_health": ["Malnutrition", "Snack", "Feast"],
	"heal_rate": ["Anemiac", "Healthy", "Vampire"]
}

const RANGE = {
	"damage": [0, 5, 10, 15],
	"movement_speed": [1, 1.5, 2],
	"attack_speed": [1, 1.5, 2],
	"bonus_health": [0, 40, 100],
	"heal_rate": [0, 1, 2]
}

@onready var player_vars = get_node("/root/PlayerVariables")
@onready var name_label = $Panel/VBoxContainer/HBoxContainer/MarginContainer2/Label
@onready var attribute_label = $Attributes
@onready var cost_label = $Panel/VBoxContainer/HBoxContainer3/MarginContainer2/Label
@onready var dmg_label = $Panel/VBoxContainer/HBoxContainer2/MarginContainer2/Label
@onready var as_label = $Panel/VBoxContainer/HBoxContainer2/MarginContainer3/Label2
var player = null
var next_upgrade = 0
var rolling_cost_cal = 0
var rolling_dmg_cal = 0
var rolling_as_cal = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	rolling_cost_cal = cost(next_upgrade)
	rolling_dmg_cal = attack_boost(next_upgrade)
	rolling_as_cal = attack_speed_boost(next_upgrade)
	
	render_weapon_stats2()
	hide()
	pass # Replace with function body.


func render_weapon_stats():
	if next_upgrade >= WEAPON_TYPE.size():
		name_label.text = "No More Upgrades..."
		attribute_label.text = ""
		return

	var weapon_dat = WEAPON_TYPE[next_upgrade]
	
	name_label.text = "Weapon: " + weapon_dat["name"]
	
	var w_labels = ""
	
	for d in DESCRIPTORS:
		var possible_labels = DESCRIPTORS[d]
		var label_idx = find_closest_number(weapon_dat[d], RANGE[d])
		
		w_labels += possible_labels[label_idx] + ", "
	
	w_labels = w_labels.left(-2)
	
	attribute_label.text = w_labels
	
func render_weapon_stats2():
	name_label.text = "Food" + " MK: " + str(int_to_roman(next_upgrade+1))
	cost_label.text = "Cost: " + str(rolling_cost_cal)
	dmg_label.text = "Heal rate: +" + "10%"
	
func int_to_roman(num: int) -> String:
	var result: String = ""
	var values: Array = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
	var numerals: Array = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]

	var i: int = 0
	while num > 0:
		while num >= values[i]:
			result += numerals[i]
			num -= values[i]
		i += 1
	return result

func upgrade():
	if player_vars.gold >= rolling_cost_cal: # condition
		#UPGRADE
		
		player_vars.bonus_heal_rate += 0.1
		player_vars.current_upgrade += 1
		player_vars.gold -= rolling_cost_cal
		next_upgrade += 1
		
		rolling_cost_cal = cost(next_upgrade)
		render_weapon_stats2()


func exit():
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#
#	utility
#
func find_closest_number(target: int, numbers: Array) -> int:
	var closest_number = 0
	var closest_distance = abs(target - numbers[0])

	for i in numbers.size():
		var distance = abs(target - numbers[i])
		if distance < closest_distance:
			closest_number = i
			closest_distance = distance

	return closest_number

func attack_boost(lvl):
	return ((100/(lvl+10)) + 1) / 2

func cost(lvl):
	return floor(pow(lvl+1, 1.5))

func attack_speed_boost(lvl):
	return attack_boost(lvl)/25.0
