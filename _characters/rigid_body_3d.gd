extends RigidBody3D

# ────────────────────── SETTINGS ──────────────────────
@export var max_speed : float = 12.0          # m/s (linear)
@export var acceleration : float = 30.0       # N per second²
@export var deceleration : float = 40.0       # N per second² when no target
@export var turn_rate : float = 5.0           # radians per second
@export var waypoint_pause : float = 1.0      # seconds to pause at each waypoint

# ────────────────────── TARGET INPUT ──────────────────────
## One of these three can be used – set the one you need in the editor.
@export var target_node_path : NodePath   ## Path to a node that will serve as the current goal
@export var waypoints : Array[Vector3]    ## Static list of world positions
@export var waypoint_index : int = 0

# ────────────────────── INTERNALS ──────────────────────
var _current_target_pos : Vector3 = Vector3.ZERO
var _is_paused : bool = false
var _pause_timer : float = 0.0

func _ready() -> void:
	set_use_custom_integrator(true)
	_update_current_target()

# ────────────────────── MAIN PHYSICS LOOP ──────────────────────
func integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if _is_paused:
		_pause_timer -= state.step
		if _pause_timer <= 0.0:
			_is_paused = false
			_advance_waypoint()
		return

	var to_target : Vector3 = (_current_target_pos - global_transform.origin).normalized()

	# Desired velocity (ignoring gravity)
	var desired_vel : Vector3 = to_target * max_speed

	# Current horizontal speed (drop vertical component)
	var current_vel_2d : Vector3 = state.linear_velocity
	current_vel_2d.y = 0.0

	# Acceleration / deceleration logic
	var vel_diff : Vector3 = desired_vel - current_vel_2d
	var accel_mag : float = acceleration if vel_diff.length() > 0 else deceleration
	var accel_vec : Vector3 = vel_diff.normalized() * accel_mag * state.step

	# Clamp to not overshoot max speed
	var new_vel : Vector3 = (current_vel_2d + accel_vec).limit_length(max_speed)
	new_vel.y = state.linear_velocity.y  # preserve vertical gravity

	state.linear_velocity = new_vel

	# Rotate body toward movement direction smoothly
	if new_vel.length() > 0.1:
		#global_transform = global_transform.looking_at(_current_target_pos, Vector3.UP)
		var current_basis : Basis = global_transform.basis
		#var target_basis : Basis = Basis(direction, Vector3.UP)
		#global_transform.basis = current_basis.slerp(target_basis, clamp(t, 0, 1))

# ────────────────────── TARGET UPDATE LOGIC ──────────────────────
func _update_current_target() -> void:
	if target_node_path != NodePath():
		var node : Node3D = get_node_or_null(target_node_path)
		if node:
			_current_target_pos = node.global_transform.origin
			return

	# If no node, fall back to waypoints list
	if waypoints.size() > 0 and waypoint_index < waypoints.size():
		_current_target_pos = waypoints[waypoint_index]
	else:
		# No valid target – stop moving
		_is_paused = true

func _advance_waypoint() -> void:
	if waypoints.size() == 0: return
	waypoint_index = (waypoint_index + 1) % waypoints.size()
	_update_current_target()

# ────────────────────── PUBLIC API (optional) ──────────────────────
## Call this from another script to command the AI to a new position.
func go_to_position(pos : Vector3, pause_at_destination : bool = false) -> void:
	_current_target_pos = pos
	_is_paused = false

## Tell the AI to follow a moving node (e.g., a player)
func follow_node(node_path : NodePath) -> void:
	target_node_path = node_path
	_update_current_target()

## Pause the AI for a moment (useful between waypoints)
func pause(seconds : float) -> void:
	_is_paused = true
	_pause_timer = seconds
