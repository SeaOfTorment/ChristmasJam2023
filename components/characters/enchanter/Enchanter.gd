extends CharacterBody3D

enum { IDLE=0, RUN=1, LAND=2, FALL=3, JUMP=4, ATTACK=5, IMPACT=6}

signal finish_control

const SPEED = 3.0
const JUMP_VELOCITY = 6
const SENSE_REDUCE = 0.5

const ATTACK_SLOW = 0.1

const JUMP_TIME = 0.8
const LAND_TIME = 0.2

const BASE_KNOCKBACK = 10
const STUN_TIME = 0.2

const ANIMATION_MAP = {
	IDLE: "Baked_Idle",
	RUN: "Baked_Run",
	FALL: "Baked_Falling",
	JUMP: "Baked_FallingStart",
	IMPACT: "Baked_Get-Hit",
	ATTACK: "Baked_Attack_Weapon",
	LAND: "Baked_FallingEnd"
}

const ACTION_DATA = {
	"basic_attack": {
		"time": 1.7,
		"impact_start": 0.5,
		"impact_end": 1.6,
		"cd": 1.8,
	}
}

@export var player: CharacterBody3D

@onready var hitbox = null

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

var curr_direction = Vector3(1, 0, 0)
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

func _ready():
	$"CanvasLayer/EnchanterUI".player = player

#
#	Black Smith Functions
#
func on_interaction(source):
	$CanvasLayer/EnchanterUI.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	print("interactwing with ", source)


func get_interaction_text():
	return "Talk to enchanter elf"


func can_interact():
	return true


func _handle_ai(_delta):
	nav_agent.target_position = target_to_attack.position
	
	if (nav_agent.target_position - position).length_squared() < 3:
		input["move_forward"] = false
		input["attack"] = true
		return
	
	input["attack"] = false
	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	
	next_path_position.y = position.y
	
	look_at(next_path_position)
	input["move_forward"] = true



#
#	Handle Attack
#
func attack(type = "basic_attack"):
	if active_cds[type] > 0: return
	attack_hit_bodies = []
	add_state(ATTACK)
	curr_action = type
	action_delta = ACTION_DATA[curr_action]["time"]
	active_cds[curr_action] = ACTION_DATA[curr_action]["cd"]


func _handle_attack(delta):
	action_delta -= delta
	if action_delta <= 0:
		hitbox.monitoring = false
		return
	add_state(ATTACK)
	
	var a_data = ACTION_DATA[curr_action]
	var t = a_data["time"] - action_delta
	
	if t >= a_data["impact_start"] and t <= a_data["impact_end"]:
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
		body.hit(1, direction, self)


func hit(_damage, direction, _source):
	action_delta = 0
	impact_dir = direction * BASE_KNOCKBACK
	impact_dir.y = 0
	if active_state != IMPACT:
		impact_timer = STUN_TIME
	add_state(IMPACT)


func _update_cd(delta):
	for key in active_cds:
		active_cds[key] -= delta


#
#	State Updates
#
func add_state(new_state):
	pending_states.append(new_state)


func _check_for_states(delta):
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
	else:
		animation.play("Baked_Idle")


#
#	Game Updates
#
func _physics_process(delta):
	if being_controlled:
		_handle_controller(delta)
		return
	
	if active_state == IMPACT:
		if (impact_timer - STUN_TIME > -0.01):
			velocity = impact_dir
	else:
		if target_to_attack: _handle_ai(delta)
		_update_cd(delta)
		if hitbox: _handle_attack(delta)
		
		if input["attack"]: attack()
		
		var local_dir = get_movement_direction()
		var dir = transform.basis * local_dir
		_update_player_direction(local_dir)
		
		velocity.x = dir.x * SPEED
		velocity.z = dir.z * SPEED
		
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
