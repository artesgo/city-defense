extends CharacterBody3D

# Expose these variables via the Godot Inspector for easy configuration
@export var target_node: NodePath = ""  # Assign to your "Command" node in the editor
@export var move_speed := 5.0    # Speed at which the enemy moves toward the Command
@export var attack_distance := 2.0  # Distance within which an attack is triggered
@export var attack_cooldown := 2.0
@export var attack := 1
@export var hp := 20.0

var target: Node3D = null              # Reference to the Command node
var _cooldown = attack_cooldown
var _hp := 0
var hit_area : Area3D                      # Reference to the child Area

func _ready() -> void:
	var root = get_tree().current_scene
	target = root.get_node("Buildings/Command")
	_hp = hp
	hit_area = $Area3D as Area3D
	if not hit_area:
		push_error("Enemy: No child named 'HitArea' found.")
		return
	hit_area.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if not target:
		return

	# ---- Get input ----------------------------------------------------
	var to_target = (target.global_position - global_position).normalized()
	# Move toward the Command
	if self.velocity.y == 0: # only move if grounded
		velocity = to_target * move_speed
		
	#TODO: Check shortest path
	
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") as float
	velocity.y -= gravity * delta

	# ---- Move ---------------------------------------------------------
	move_and_slide()

	# Check for attack condition
	var distance_to_target = (global_position - target.global_position).length()
	if distance_to_target <= attack_distance and _cooldown < 0:
		_attack()

func _attack() -> void:
	# Here, you can add logic to deal damage or trigger an event
	# Example: Emit a signal to notify other nodes about the attack
	emit_signal("enemy_attack", self)
	

func take_damage(amount : int) -> void:
	hp -= amount
	print("%s took %d dmg, HP left: %d" % [name, amount, hp])

	if hp <= 0:
		die()


func die() -> void:
	print("%s died!" % name)
	queue_free()

##########################
# --- SIGNAL HANDLERS -- #
##########################

func _on_body_entered(body : Node) -> void:
	print_debug('colliding with bullet')
	# 1️⃣ Quick sanity checks
	if not body or not body.is_inside_tree():
		return

	# 2️⃣ Identify projectiles – we use a group name for flexibility.
	if not body.is_in_group("Projectiles"):
		return
	var proj_damage : int = 10          # default fallback

	if body.has_method("get_damage"):        # projectile exposes a method
		proj_damage = body.get_damage()
	elif "damage" in body:                  # or it has an exported property
		proj_damage = float(body.damage)

	take_damage(proj_damage)

	# Optional: let the projectile react (e.g., play hit effect)
	if body.has_method("on_hit"):
		body.on_hit()

	# Destroy the projectile so it doesn't keep colliding.
	body.queue_free()
