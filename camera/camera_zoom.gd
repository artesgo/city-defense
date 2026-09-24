extends Camera3D

##########################
# --- Public Settings ---
##########################

@export var min_height : float = 8.0      # lowest Y the camera can go to
@export var max_height : float = 64.0     # highest Y the camera can go to
@export var lerp_speed : float = 8.0      # how fast the camera moves (units per second)

# Optional: keys that increase/decrease height
@export var key_zoom_in  : String = "zoom_in"
@export var key_zoom_out : String = "zoom_out"

# If you want to use mouse wheel, set this flag to true
@export var enable_mouse_wheel : bool = true

var _desired_height : float = 0.0   # target Y‑position

var current_zoom = 0.0

func _ready() -> void:
	# Make sure the camera starts at a sane height
	if global_transform.origin.y == 0.0:
		_desired_height = clamp(min_height, min_height, max_height)
	else:
		_desired_height = clamp(global_transform.origin.y, min_height, max_height)

	# Register actions (you can also add them in Project Settings → Input Map)
	_ensure_input_actions()

func _process(delta: float) -> void:
	_handle_user_input()
	_update_camera_position(delta)

##########################
# --- Helper Methods ---
##########################

func _ensure_input_actions() -> void:
	# Add actions if they don't exist yet
	var map = InputMap

	if not map.has_action(key_zoom_in):
		map.add_action(key_zoom_in)
		map.action_add_event(key_zoom_in, InputEventKey.new().set_scancode(KEY_PLUS))
		map.action_add_event(key_zoom_in, InputEventKey.new().set_scancode(KEY_KP_ADD))

	if not map.has_action(key_zoom_out):
		map.add_action(key_zoom_out)
		map.action_add_event(key_zoom_out, InputEventKey.new().set_scancode(KEY_MINUS))
		map.action_add_event(key_zoom_out, InputEventKey.new().set_scancode(KEY_KP_SUBTRACT))

func _handle_user_input() -> void:
	# Keyboard zoom
	if Input.is_action_just_released(key_zoom_in):
		_desired_height = clamp(_desired_height - 1.5, min_height, max_height)
	elif Input.is_action_just_released(key_zoom_out):
		_desired_height = clamp(_desired_height + 1.5, min_height, max_height)

func _update_camera_position(delta: float) -> void:
	var current_y = global_transform.origin.y
	var new_y = lerp(current_y, _desired_height, lerp_speed * delta)
	# Keep X & Z unchanged; only Y is affected
	var pos = global_transform.origin
	pos.y = new_y
	if new_y != current_zoom:
		current_zoom = new_y
	global_transform.origin = pos

##########################
# --- Optional: Expose ---
##########################

func set_desired_height(height: float) -> void:
	_desired_height = clamp(height, min_height, max_height)

func get_desired_height() -> float:
	return _desired_height
