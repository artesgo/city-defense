extends CharacterBody3D

# ────────────────────── Settings ──────────────────────
@export var speed : float = 4.0            # meters per second
@export var stop_distance : float = 6     # distance to target before stopping
@export var carry : int = 1
@export var use_obstacle_avoidance : bool = true   # toggles the RayCast check

@onready var raycast : RayCast3D = $RayCast3D    # will be null if you removed it
signal on_task
# ────────────────────── Cached Nodes ──────────────────────
var _target_node : NodePath          # set this in the editor or via code
var _task : Task
# ────────────────────── State ──────────────────────
var _moving : bool = false
var _carrying : bool = false
var _pickingup : bool = false
var _pickingup_anim : bool = false
var _droppingoff : bool = false
var _droppingoff_anim : bool = false
var _cooldown : float = 0.0

func _process(delta) -> void:
	# when dropping off or picking up, stay around for a while
	if _cooldown > 0:
		print_debug(_cooldown)
		_cooldown -= delta
		if _cooldown < 0:
			_cooldown = 0
			_pickingup_anim = false
			_droppingoff_anim = false
		return
	# when not moving, or idle, check if task is pending
	if not _moving and _task and _task.quantity > 0:
		if _carrying:
			start_moving_to(get_node(_task.destination))
			_droppingoff = true
		else:
			start_moving_to(get_node(_task.source))
			_pickingup = true

func _physics_process(delta: float) -> void:
	if not _moving:
		return

	var target_pos : Vector3 = get_node(_target_node).global_transform.origin
	var to_target : Vector3 = target_pos - global_transform.origin
	var distance : float = to_target.length()

	# 1️⃣ Stop when we’re close enough
	if distance <= stop_distance and _moving:
		_stop()
		return

	# 2️⃣ Desired direction (normalized)
	var desired_dir : Vector3 = to_target.normalized()

	# 3️⃣ Optional obstacle avoidance
	if use_obstacle_avoidance and raycast != null:
		# Cast forward from the player’s origin
		#raycast.cast_to = desired_dir * 2.0   # 2m ahead – tweak as needed
		raycast.force_raycast_update()
		if raycast.is_colliding():
			# Simple “steer away” by rotating the direction vector
			var hit_normal : Vector3 = raycast.get_collision_normal()
			desired_dir = (desired_dir - hit_normal * 0.5).normalized()

	# 4️⃣ Compute velocity & move
	velocity = desired_dir * speed
	
	move_and_slide()

# ────────────────────── Public API ──────────────────────
func start_moving_to(target : Node) -> void:
	if target == null:
		push_warning("NavNoMesh.start_moving_to() called with a null target.")
		return

	_target_node = target.get_path()
	_moving = true

func stop() -> void:
	_stop()

func _stop() -> void:
	_moving = false
	velocity = Vector3.ZERO
	if _pickingup:
		_carrying = true
		_cooldown = _task.durationSrc
		_pickingup_anim = true
		# emit pickup, queue.update_front(
		pass
		
	if _droppingoff:
		_carrying = false
		_droppingoff_anim = true
		_cooldown = _task.durationDest
		# emit dropoff
		pass

	_pickingup = false
	_droppingoff = false

func assign(task: Task):
	_task = task
	
func unassign():
	_task = null
