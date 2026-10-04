# Tower.gd
extends Node3D

##########################
# === EXPORT SETTINGS ==== #
##########################

## The scene that will be instantiated when we fire.
@export var projectile_scene : PackedScene
@export var projectile_duration : float = 1.0
@export var projectile_dmg : float = 5.0
@export var projectile_spd : float = 60.0

## How many shots per second (higher = faster).
@export_range(0.1, 10.0) var fire_rate : float = 2.0

## Distance within which enemies can be targeted.
@export var range : float = 20.0

## Turn‑speed in radians/sec. 0 → instant turn.
@export var rotation_speed : float = 4.0

## Path from the main scene to the node that contains all live enemies.
# (e.g. "EnemySpawner/Enemies")
@export var enemy_container_path : NodePath = "EnemySpawner"

##########################
# === INTERNALS ======== #
##########################

var _time_since_last_shot := 0.0
var _enemy_container : Node3D   # the “Enemies” node

func _ready() -> void:
	if not projectile_scene:
		push_error("Tower: projectile_scene is NOT set!")
		return

	# Grab the container once (avoids walking up the tree every frame)
	var root = get_tree().current_scene
	_enemy_container = root.get_node_or_null(enemy_container_path) as Node3D
	if not _enemy_container:
		push_error("Tower: cannot find node at '%s'" % enemy_container_path)

##########################
# === FRAME UPDATE ===== #
##########################

func _process(delta : float) -> void:
	if not _enemy_container:
		return

	# 1️⃣ Find the nearest enemy
	var target = _get_nearest_enemy()
	if not target:
		return   # nothing in range

	# 2️⃣ Rotate toward it (smoothly or instantly)
	_look_at_target(target, delta)

	# 3️⃣ Fire when cooldown allows
	_time_since_last_shot += delta
	var time_between_shots = 1.0 / fire_rate
	if _time_since_last_shot >= time_between_shots:
		_fire_projectile(target)
		_time_since_last_shot = 0.0

##########################
# === HELPERS ======== #
##########################

func _get_nearest_enemy() -> Node3D:
	var nearest : Node3D
	var nearest_dist_sq := range * range   # use squared distance for speed

	for child in _enemy_container.get_children():
		if not child is Node3D:  # ignore non‑spatial nodes
			continue
		var dist_sq = global_transform.origin.distance_squared_to(child.global_transform.origin)
		if dist_sq <= nearest_dist_sq:
			nearest = child as Node3D
			nearest_dist_sq = dist_sq

	return nearest

func _look_at_target(target : Node3D, delta : float) -> void:
	# Compute the direction from tower to target in the XZ plane
	var dir = (target.global_transform.origin - global_transform.origin).normalized()
	dir.y = 0   # keep rotation on horizontal plane
	if dir.length() == 0: return

	var target_rotation := Vector3(0, atan2(dir.x, dir.z), 0)
	if rotation_speed > 0:
		rotation.y = lerp_angle(rotation.y, target_rotation.y, rotation_speed * delta)
	else:
		rotation.y = target_rotation.y

func _fire_projectile(target : Node3D) -> void:
	print_debug('fire projectile')
	var projectile = projectile_scene.instantiate() as RigidBody3D
	projectile.duration = projectile_duration
	if not projectile:
		push_error("Tower: projectile scene did NOT return a RigidBody3D!")
		return
	get_tree().current_scene.get_node('Projectiles').add_child(projectile)

	# Place it at the tower’s muzzle (you can adjust this offset)
	projectile.global_transform.origin = global_transform.origin + Vector3(0, 1.5, 0)

	# Give it an initial velocity toward the target
	var dir = (target.global_transform.origin - projectile.global_transform.origin).normalized()
	if projectile is RigidBody3D:
		projectile.linear_velocity = dir * projectile_spd

	# Optional: tell the projectile who its target is (if it needs to track)
	if projectile.has_method("set_target"):
		projectile.set_target(target)

	# Add it to the scene so physics runs
	#get_tree().current_scene.add_child(projectile)
