extends CharacterBody3D

enum { IDLE=0, RUN=1, LAND=2, FALL=3, JUMP=4, ATTACK=5 }

const SPEED = 5.0
const JUMP_VELOCITY = 6
const SENSE_REDUCE = 0.5

const ATTACK_SLOW = 0.1

const JUMP_TIME = 0.8
const LAND_TIME = 0.2

const ANIMATION_MAP = {
	IDLE: "idle",
	RUN: "run",
	FALL: "AirTime",
	JUMP: "jump",
	ATTACK: "attack1",
	LAND: "Land"
}

const ACTION_DATA = {
	"basic_attack": {
		"time": 1.7,
		"impact_start": 0.8,
		"impact_end": 1.1,
		"cd": 1.8,
	}
}

@onready var camera_mount = $CameraMount
@onready var hitbox = $AttackHitbox

@onready var mesh = $betterAnim
@onready var animation = $betterAnim/AnimationPlayer

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


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


#
#	Input Monitoring
#
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens_x * SENSE_REDUCE))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * mouse_sens_y * SENSE_REDUCE))
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _check_input_pressed(action):
	if Input.is_action_pressed(action):
		input[action] = true
	else:
		input[action] = false


func _check_input_just_pressed(action):
	if Input.is_action_just_pressed(action):
		input[action] = true
	else:
		input[action] = false


func _handle_input():
	_check_input_pressed("move_left")
	_check_input_pressed("move_right")
	_check_input_pressed("move_forward")
	_check_input_pressed("move_backwards")
	_check_input_just_pressed("jump")
	_check_input_pressed("attack")


#
#	Handle Attack
#
func attack(type = "basic_attack"):
	if active_cds[type] > 0: return
	add_state(ATTACK)
	curr_action = type
	action_delta = ACTION_DATA[curr_action]["time"]
	active_cds[curr_action] = ACTION_DATA[curr_action]["cd"]


func _handle_attack(delta):
	action_delta -= delta
	if action_delta < 0:
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
	if (body.has_method("hit")):
		var direction = body.global_position - global_position
		direction.y += 1
		body.hit(1, direction)


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
		animation.play("idle")


#
#	Game Updates
#
func _physics_process(delta):
	_handle_input()
	_update_cd(delta)
	_handle_attack(delta)
	
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
	hitbox.rotation.y = mesh.rotation.y + deg_to_rad(180)


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
