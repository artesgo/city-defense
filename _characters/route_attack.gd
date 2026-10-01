extends CharacterBody3D

# Expose these variables via the Godot Inspector for easy configuration
@export var target_node: NodePath = ""  # Assign to your "Command" node in the editor
@export var move_speed: float = 5.0    # Speed at which the enemy moves toward the Command
@export var attack_distance: float = 2.0  # Distance within which an attack is triggered

var target: Node3D = null              # Reference to the Command node
var has_attacked: bool = false         # To prevent repeated attacks

func _ready() -> void:
	target = get_node("../../../PlayerControlled/Command")

func _physics_process(delta: float) -> void:
	if not target:
		return

	# ---- Get input ----------------------------------------------------
	var to_target = (target.global_position - global_position).normalized()
	# Move toward the Command
	if self.velocity.y == 0: # only move if grounded
		velocity = to_target * move_speed
	
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") as float
	velocity.y -= gravity * delta

	# ---- Move ---------------------------------------------------------
	move_and_slide()

	# Check for attack condition
	var distance_to_target = (global_position - target.global_position).length()
	if distance_to_target <= attack_distance and not has_attacked:
		_attack()
		has_attacked = true

func _attack() -> void:
	print("Enemy attacked the Command node!")
	
	# Here, you can add logic to deal damage or trigger an event
	# Example: Emit a signal to notify other nodes about the attack
	emit_signal("enemy_attack", self)
