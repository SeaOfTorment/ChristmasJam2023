extends Node3D

const NPC_DATA = [
	{
		"type": 2,	# EMO
		"health": 2,
		"damage": 20,
		"loot": 1,
		"as": 1,
		"ms": 1.3
	},
	{
		"type": 5,	# REBEL
		"health": 10,
		"damage": 5,
		"loot": 1,
		"as": 1,
		"ms": 1
	},
	{
		"type": 6,	# REINDEER
		"health": 5,
		"damage": 1,
		"loot": 1,
		"as": 3,
		"ms": 0.7
	},
	{
		"type": 0,	# BLACKSMITH
		"health": 10,
		"damage": 5,
		"loot": 1,
		"as": 1,
		"ms": 1
	},
	{
		"type": 1,	# COOK
		"health": 10,
		"damage": 5,
		"loot": 1,
		"as": 1,
		"ms": 1
	},
	{
		"type": 3,	# ENCHANTOR
		"health": 10,
		"damage": 5,
		"loot": 1,
		"as": 1,
		"ms": 1
	},
	{
		"type": 4,	# FRIENDLY
		"health": 10,
		"damage": 5,
		"loot": 1,
		"as": 1,
		"ms": 1
	},
	{
		"type": 7,	# FRIENDLY
		"health": 10,
		"damage": 5,
		"loot": 1,
		"as": 1,
		"ms": 1
	},
]

var npcs = preload("res://components/characters/npc/Npc.tscn")

@export var spawner_level = 1
@export var spawn_rate = 0.2
@export var capacity = 6
@export var target_to_attack : CharacterBody3D
@export var spawnables : Array[int] = [0, 1, 2]

@onready var alive_enemies = $Enemies
@onready var dead_enemies = $DeadEnemies

var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timer > 0 or alive_enemies.get_child_count() >= capacity:
		timer -= delta
		return
	
	timer = 1 / spawn_rate
	
	var idx = spawnables[randi() % spawnables.size()]
	var dat = NPC_DATA[idx]
	
	var new_spawn = npcs.instantiate()
	new_spawn.max_health = dat["health"] * spawner_level
	new_spawn.damage = dat["damage"] * spawner_level
	new_spawn.model = dat["type"]
	new_spawn.loot_amount = dat["loot"] * spawner_level
	new_spawn.attack_speed = dat["as"]
	new_spawn.movement_speed = dat["ms"]
	
	new_spawn.has_died.connect(move_to_dead)
	new_spawn.position = $Marker3D.global_position
	new_spawn.crazy = true
	
	if target_to_attack:
		new_spawn.target_to_attack = target_to_attack
	
	alive_enemies.add_child(new_spawn)


func move_to_dead(dead, _killer):
	dead.reparent(dead_enemies)

