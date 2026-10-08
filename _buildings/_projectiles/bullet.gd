# Projectile.gd – a simple timed‑lifespan RigidBody3D

extends RigidBody3D

## How many seconds the projectile should live before it disappears.
@export var duration : float = 5.0
@export var dmg := 1.0
@export var deceleration := 0.0

## Internal counter that we’ll tick down every frame.
var _remaining_time := 0.0

func _ready() -> void:
	# Initialise the internal timer with whatever the exported value is
	_remaining_time = duration

func _physics_process(delta: float) -> void:
	# Apply deceleration to current velocity
	var speed = linear_velocity.length()
	if speed > 0 and deceleration != 0.0:
		var new_speed = max(0, speed - deceleration * delta)
		linear_velocity = linear_velocity.normalized() * new_speed

	# Tick the timer down
	_remaining_time -= delta

	# When it runs out (or was already negative), remove ourselves.
	if _remaining_time <= 0.0:
		queue_free()

func get_damage() -> float:
	return dmg

func on_hit() -> void:
	#play particle effects
	self.queue_free()
	return
