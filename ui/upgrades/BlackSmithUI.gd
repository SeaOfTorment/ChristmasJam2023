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

@onready var name_label = $Name
@onready var attribute_label = $Attributes
var player = null

var next_upgrade = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	render_weapon_stats()
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


func upgrade():
	if true: # condition
		next_upgrade += 1
		render_weapon_stats()


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
