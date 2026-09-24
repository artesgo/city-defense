extends CharacterBody3D

class_name Navigator

# ────────────────────── Settings ──────────────────────
@export var speed : float = 4.0            # meters per second
@export var stop_distance : float = 6     # distance to target before stopping
@export var carry : int = 1
@export var turn_speed : float = 5.0
@export var ray_length : float = 4.0
@onready var forward : RayCast3D = $Rays/Forward
@onready var left : RayCast3D = $Rays/Left
@onready var right : RayCast3D = $Rays/Right
	# will be null if you removed it
#signal on_task
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

	# 1. Calculate direction to the target
	desired_dir.y = 0 # Keep movement on a 2D plane if applicable

	# 2. Blend in avoidance forces based on raycast collisions
	var avoidance_dir: Vector3 = Vector3.ZERO
	if forward.is_colliding():
		# Push away from whatever the forward ray hits using its surface normal
		avoidance_dir += forward.get_collision_normal()

	if left.is_colliding():
		# Push right if left ray hits something
		avoidance_dir += global_transform.basis.x

	if right.is_colliding():
		# Push left if right ray hits something
		avoidance_dir -= global_transform.basis.x

	# 3. Combine target direction and avoidance steering
	var final_dir: Vector3 = desired_dir
	if avoidance_dir != Vector3.ZERO:
		# Blend the avoidance maneuver with original target direction
		final_dir = (desired_dir + avoidance_dir * 8).normalized()

	# 4. Smoothly rotate character towards the movement direction
	if final_dir.length_squared() > 0.001:
		var target_rotation = atan2(-final_dir.x, -final_dir.z)
		rotation.y = rotate_toward(rotation.y, target_rotation, delta * 5.0)

	# 4️⃣ Compute velocity & move
	velocity = final_dir * speed

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
