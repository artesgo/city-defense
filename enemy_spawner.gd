extends Node3D

class_name EnemySpawner

##########################
# === CONFIGURATION ==== #
##########################

@export var spawn_interval : float = 2.0
	# How often to spawn (seconds).

@export var spawn_radius : float = 15.0
	# Radius around the spawner where enemies will appear.

@export var enemy_scenes : Array[PackedScene] = []
	# Drag & drop your enemy scenes into this list in the Inspector.
	# Example: [ preload("res://scenes/EnemyGoblin.tscn"),
	#            preload("res://scenes/EnemyOrc.tscn") ]

@export var spawn_on_start : bool = true
	# If true, the first spawn happens immediately when the game starts.


##########################
# === INTERNALS ======== #
##########################

var _timer : Timer
var _rng   := RandomNumberGenerator.new()

func _ready() -> void:
	if enemy_scenes.is_empty():
		push_error("EnemySpawner: No enemy scenes assigned!")
		return

	# Grab or create the Timer node
	_timer = $Timer as Timer
	if not _timer:
		_timer = Timer.new()
		add_child(_timer)
		_timer.name = "Timer"

	_timer.wait_time  = spawn_interval
	_timer.one_shot   = false
	_timer.autostart  = true
	_timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	
	# Optionally fire the first spawn immediately
	if spawn_on_start:
		spawn_enemy()

##########################
# === CALLBACKS ======== #
##########################

func _on_timer_timeout() -> void:
	spawn_enemy()


##########################
# === SPAWN LOGIC ====== #
##########################

func spawn_enemy() -> void:
	# Pick a random enemy type
	var idx = _rng.randi_range(0, enemy_scenes.size() - 1)
	var scene : PackedScene = enemy_scenes[idx]

	# Instantiate and set its position
	var instance : Node3D = scene.instantiate()
	if not instance:
		push_error("Failed to instantiate enemy scene.")
		return

	# Random offset inside the spawn radius (XZ plane only)
	var random_offset := Vector3(
		_rng.randf_range(-spawn_radius, spawn_radius),
		0.0,
		_rng.randf_range(-spawn_radius, spawn_radius)
	)
	
	# Put the new enemy instance under EnemySpawner
	var enemies_root = get_tree().current_scene.get_node('EnemySpawner')

	# Add child before global transform, otherwise godot complains
	enemies_root.add_child(instance)
	instance.global_transform.origin = global_transform.origin + random_offset
	# Add it under the Enemies child node (not directly to root)
	_timer.start(spawn_interval)
