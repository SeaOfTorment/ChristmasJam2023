extends Node3D

var red_gift = preload("res://components/prefabs/red_pres_rig.tscn")
var green_gift = preload("res://components/prefabs/green_pres_rig.tscn")
var snowman = preload("res://components/prefabs/snowman_rig.tscn")
var banana = preload("res://components/prefabs/banana_inh.tscn")
var bear = preload("res://components/prefabs/bear_inh.tscn")

var current_music = 0

# Define audio players
@onready var audioPlayer1 : AudioStreamPlayer = $game_music

var music_changed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var arr = [red_gift, green_gift, snowman, banana, bear]
	var markers = $boxes_pawn_points.get_children()
	while(true):
		var rng = RandomNumberGenerator.new()
		var gift_inst = arr[rng.randi_range(0, arr.size()-1)].instantiate()
		$gift_boxes.add_child(gift_inst)
		rng = RandomNumberGenerator.new()
		gift_inst.position = markers[rng.randi_range(0, 5)].position
		await get_tree().create_timer(0.35).timeout


func _on_santa_boss_has_died(_dead, _killer):

	await get_tree().create_timer(3).timeout
	
	get_tree().change_scene_to_packed(load("res://levels/scenes/snow_town_scene/snow_town.tscn"))
	pass # Replace with function body.



func _on_music_one_body_entered(body):
	if body == $Player and not music_changed:
		music_changed = true
		$game_music.stream = load("res://sounds/music/JameGamChristmas_Music_Combat_1.0 (1).ogg")
		$game_music.play()
		$game_music.autoplay = true
	pass # Replace with function body.
