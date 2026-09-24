# Task.gd
@tool
extends Resource          # <‑ makes it serialisable & editable

class_name Task           # registers as “Task” in the project

@export var id : String = ''
@export var quantity : int = 1
@export var spoken : int = 0
@export var durationSrc : int = 0    # how long the character stays at source to pick up
@export var durationDest : int = 0   # how long the character stays at destination to drop off
@export var source : NodePath = NodePath("")      # node that owns the items
@export var destination : NodePath = NodePath("") # where to put them

# Optional: a tiny helper so we can log/debug easily
func _to_string() -> String:
	return "Task(q=%d, src=%s → dst=%s)" % [quantity, source, destination]
