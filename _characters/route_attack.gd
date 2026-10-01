extends CharacterBody3D

# Expose these variables via the Godot Inspector for easy configuration
@export var target_node: NodePath = ""  # Assign to your "Command" node in the editor
@export var move_speed: float = 5.0    # Speed at which the enemy moves toward the Command
@export var attack_distance: float = 1.0  # Distance within which an attack is triggered

var target: Node3D = null              # Reference to the Command node
var has_attacked: bool = false         # To prevent repeated attacks

func _ready() -> void:
	set_target("/root/PlayerControlled/Command")
	print_debug('attach the command center')


func _process(delta: float) -> void:
	if not target or not target.is_valid():
		return

	# Calculate movement direction
	var to_target = (target.global_position - global_position).normalized()
	
	# Move toward the Command
	velocity = to_target * move_speed
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

func set_target(new_target: NodePath):
	target_node = new_target
