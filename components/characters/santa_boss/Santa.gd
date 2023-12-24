extends CharacterBody3D

enum { IDLE=0, RUN=1, LAND=2, FALL=3, JUMP=4, ATTACK=5, IMPACT=6, DEAD=100}
enum AI_STATE { AI_IDLE=0, AI_WANDER=1 }

signal finish_control
signal has_died(dead, killer)

const KILL_HEIGHT = -100
const SPEED = 3.0
const JUMP_VELOCITY = 6
const SENSE_REDUCE = 0.5

const ATTACK_SLOW = 0.1

const JUMP_TIME = 0.8
const LAND_TIME = 0.2

const BASE_KNOCKBACK = 10
const STUN_TIME = 0.2

const DIRECTIONS = [
	Vector3(1, 0, 0),
	Vector3(0, 0, 1),
	Vector3(-1, 0, 0),
	Vector3(0, 0, -1)
]

const ANIMATION_MAP = {
	IDLE: "Baked_Idle",
	RUN: "Baked_Run",
	FALL: "Baked_Falling",
	JUMP: "Baked_FallingStart",
	IMPACT: "Baked_Get-Hit",
	ATTACK: "Baked_Attack_Weapon",
	LAND: "Baked_FallingEnd",
	DEAD: "Baked_Death"
}

const ACTION_DATA = {
	"basic_attack": {
		"time": 1.7,
		"impact_start": 0.4,
		"impact_end": 0.7,
		"cd": 1.8,
	}
}

@export_enum("BlackSmithElf", "CookElf", "EmoElf", "EnchanterElf", "FriendlyElf", "RebelElf", "Reindeer", "SantaElf", "Yeti") var model
@export var npc_name : String = "Santa"
@export var text_lines : Array[String]
@export var interactable : bool
@export var max_health = 5000
@export var damage = 30
@export var loot_amount = 1000000
@export var detect_range = 5
@export var movement_speed = 1.5
@export var attack_speed = 2

@export var crazy : bool = false

var health
var killer = self
var killer_timer = 0

@onready var hitbox = $character_model/rig_deform/Skeleton3D/BoneAttachment3D/AnvilHammer/AttackHitbox

@onready var mesh = $character_model
@onready var animation = $character_model/AnimationPlayer


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


var mouse_sens_x = 0.1
var mouse_sens_y = 0.1

var input = {
	"move_left": false,
	"move_right": false,
	"move_forward": false,
	"move_backwards": false,
	"jump": false,
	"attack": false,
}

var active_cds = {
	"basic_attack": 0
}

var curr_direction = Vector3(0, 0, 1)
var curr_action = "basic_attack"
var action_delta = 0

var pending_states = []
var active_state = IDLE

var jump_state_cd = 0
var land_state_cd = 0

var impact_timer = 0
var impact_dir = Vector3(0, 0, 0)

var attack_hit_bodies = []

#
# Animation vars
#
const DEFAULT_CONTROL = {
	"animation": "idle",
	"start_rotation": null,
	"end_rotation": null,
	"start_position": null,
	"end_position": null,
	"time": 1,
	"end_animation": "idle",
	"relative_movement": false,
	"rotate_with_movement": true,
	"immediate_rotation": true,
}

var being_controlled = false
var control_time = 0
var current_control = DEFAULT_CONTROL.duplicate()


@export var target_to_attack : CharacterBody3D
@onready var nav_agent = $NavigationAgent3D

var ai_timer = 0
var curr_ai_state = AI_STATE.AI_IDLE
var wander_dir = DIRECTIONS[0]

func _ready():
	health = max_health
	$SubViewport/NpcHpOverhead.max_value = health
	$SubViewport/NpcHpOverhead.value = health



#
#	Interaction Functions
#
func on_interaction(_source):
	$CanvasLayer/TextBox.display_text(npc_name, text_lines)


func get_interaction_text():
	return "Talk to " + npc_name


func can_interact():
	return interactable


func _handle_ai(delta):
	ai_timer -= delta
	nav_agent.target_position = target_to_attack.position
	
	var dist = (nav_agent.target_position - global_position).length_squared()
	if dist > detect_range * detect_range:
		if ai_timer > 0:
			_do_passive_ai(delta)
		else:
			_random_passive()
		return

	
	input["attack"] = false
	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	
	next_path_position.y = global_position.y
	
	if dist < 3 or global_transform.origin.is_equal_approx(next_path_position):
		input["move_forward"] = false
		input["attack"] = true
		return
	
	look_at(next_path_position)
	input["move_forward"] = true


func _random_passive():
	curr_ai_state = randi() % 2 as AI_STATE
	match(curr_ai_state):
		AI_STATE.AI_IDLE:
			ai_timer = 2
			pass
		AI_STATE.AI_WANDER:
			ai_timer = 1
			wander_dir = DIRECTIONS[randi() % DIRECTIONS.size()]


func _do_passive_ai(_delta):
	match(curr_ai_state):
		AI_STATE.AI_WANDER:
			look_at(global_position + wander_dir)
			input["move_forward"] = true
		_:
			input["move_forward"] = false

#
#	Handle Attack
#
func attack(type = "basic_attack"):
	if active_cds[type] > 0: return
	attack_hit_bodies = []
	add_state(ATTACK)
	curr_action = type
	action_delta = ACTION_DATA[curr_action]["time"] / attack_speed
	active_cds[curr_action] = ACTION_DATA[curr_action]["cd"] / attack_speed


func _handle_attack(delta):
	action_delta -= delta
	if action_delta <= 0:
		hitbox.monitoring = false
		return
	add_state(ATTACK)
	
	var a_data = ACTION_DATA[curr_action]
	var t = a_data["time"] / attack_speed - action_delta
	
	if (
		t >= a_data["impact_start"] / attack_speed and 
		t <= a_data["impact_end"] / attack_speed
		):
		hitbox.monitoring = true
	else:
		hitbox.monitoring = false


#
#	ETC
#
func _handle_hitbox_collision(body):
	if (body.has_method("hit") && body != self):
		if (body in attack_hit_bodies):
			return
		attack_hit_bodies.append(body)
		var direction = (body.global_position - global_position).normalized()
		direction.y = 0
		body.hit(damage, direction, self)


func hit(incoming_damage, direction, source):
	$AudioStreamPlayer3D.play()
	action_delta = 0
	impact_dir = direction * BASE_KNOCKBACK
	impact_dir.y = 0
	if active_state != IMPACT:
		impact_timer = STUN_TIME
	add_state(IMPACT)
	health -= incoming_damage
	$SubViewport/NpcHpOverhead.value = health
	
	killer = source
	killer_timer = 10


func _update_cd(delta):
	for key in active_cds:
		active_cds[key] -= delta


func loot(_gold):
	if crazy:
		change_target()
	pass


func change_target():
	var crazies = get_tree().get_nodes_in_group("crazies")
	target_to_attack = crazies[randi() % crazies.size()]
	detect_range = 100
	


#
#	State Updates
#
func add_state(new_state):
	pending_states.append(new_state)


func _check_for_states(delta):
	if active_state == DEAD:
		add_state(DEAD)
		return
	if not is_on_floor():
		add_state(FALL)
		land_state_cd = LAND_TIME
	if is_on_floor() and land_state_cd > 0:
		land_state_cd -= delta
		add_state(LAND)
	if jump_state_cd > 0:
		jump_state_cd -= delta
		add_state(JUMP)
	
	if active_state == IMPACT:
		if impact_timer > 0:
			impact_timer -= delta
			add_state(IMPACT)


func _run_state_update():
	var new_state = pending_states.max()
	pending_states.clear()
	if new_state != active_state:
		var prev_state = active_state
		active_state = new_state
		_state_update(active_state, prev_state)


func _state_update(state, _prev_state): #underscored to prevent error on unused var
	if state in ANIMATION_MAP:
		animation.play(ANIMATION_MAP[state])
		if state == ATTACK:
			var a_data = ACTION_DATA["basic_attack"]
			animation.speed_scale = animation.current_animation_length / (a_data["time"] / attack_speed)
		else:
			animation.speed_scale = 1
	else:
		animation.speed_scale = 1
		animation.play("Baked_Idle")


func _check_for_death():
	if health <= 0 or position.y < KILL_HEIGHT:
		if killer_timer > 0:
			if not is_instance_valid(killer):
				killer = null
			if killer:
				if killer.has_method("loot"):
					killer.loot(randi_range(loot_amount, loot_amount * 2))
		has_died.emit(self, killer)
		add_state(DEAD)
		print("has DIED!!!!!")
		interactable = false
		remove_from_group("crazies")
		set_physics_process(false)
		$CollisionShape3D.set_deferred("disabled", true)
		$SubViewport/NpcHpOverhead.queue_free()
		#queue_free()



#
#	Game Updates
#
func _physics_process(delta):
	if active_state == DEAD:
		return
	
	killer_timer -= delta
	_check_for_death()
	
	if being_controlled:
		_handle_controller(delta)
		return
	
	if active_state == IMPACT:
		if (impact_timer - STUN_TIME > -0.01):
			velocity = impact_dir
	else:
		if target_to_attack and is_instance_valid(target_to_attack):
			_handle_ai(delta)
		
		_update_cd(delta)
		if hitbox: _handle_attack(delta)
		
		if input["attack"]: attack()
		
		var local_dir = get_movement_direction()
		var dir = transform.basis * local_dir
		_update_player_direction(local_dir)
		
		velocity.x = dir.x * SPEED * movement_speed
		velocity.z = dir.z * SPEED * movement_speed
		
		if not is_on_floor():
			velocity.y -= gravity * delta
		
		if input["jump"] and is_on_floor():
			jump_state_cd = JUMP_TIME
			velocity.y = JUMP_VELOCITY
		
		if dir.length_squared() > 0:
			add_state(RUN)
	
	move_and_slide()
	_check_for_states(delta)
	_run_state_update()


func _update_player_direction(local_dir):
	if (local_dir.length_squared() > 0): 
		var temp = local_dir
		temp.y = 0
		curr_direction = temp
	
	mesh.transform = mesh.transform.interpolate_with(mesh.transform.looking_at(curr_direction * -10), 0.2)
	hitbox.transform = mesh.transform


#
#	animation control
#
func set_control(params = {}):
	current_control = DEFAULT_CONTROL.duplicate()
	
	for key in params:
		current_control[key] = params[key]
	
	control_time = 0


func _handle_controller(delta):
	if control_time == 0:
		if current_control["start_position"] == null: current_control["start_position"] = position
		if current_control["start_rotation"] == null: current_control["start_rotation"] = global_rotation.y
		if current_control["end_position"] == null: current_control["end_position"] = position
		if current_control["end_rotation"] == null: current_control["end_rotation"] = global_rotation.y
		if current_control["relative_movement"]:
			current_control["end_position"] = current_control["end_position"] + current_control["start_position"] 
		var dir = current_control["end_position"] - current_control["start_position"]
		if current_control["rotate_with_movement"] and dir.length_squared() > 0:
			current_control["end_rotation"] = Vector3(0, 0, -1).angle_to(dir)
		animation.play(current_control["animation"])
	control_time += delta
	
	var curr_percent = control_time / current_control["time"]
	curr_percent = clamp(curr_percent, 0, 1)
	
	global_position = current_control["start_position"].lerp(current_control["end_position"], curr_percent)
	if current_control["immediate_rotation"]:
		global_rotation.y = current_control["end_rotation"]
	else:
		global_rotation.y = (
				((current_control["end_rotation"] - current_control["start_rotation"])
				* curr_percent) + current_control["start_rotation"])


func move_control(animation_name : String, points : Array, time : float, relative = true):
	var dt = time / points.size()

	for v in points:
		set_control({
			"animation": animation_name,
			"end_position": v,
			"time": dt,
			"relative_movement": relative
		})
		
		await get_tree().create_timer(dt).timeout


#
#	Utility
#
func get_movement_direction():
	var dir = Vector3(0, 0, 0)
	if input["move_left"]: dir.x -= 1
	if input["move_right"]: dir.x += 1
	if input["move_forward"]: dir.z -= 1
	if input["move_backwards"]: dir.z += 1
	
	return dir.normalized()


func get_cd(type = "basic_attack"):
	return {
		"active_cd": active_cds[type],
		"cd": ACTION_DATA[type]["cd"]
	}
