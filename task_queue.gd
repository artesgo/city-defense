# res://utils/UuidUtil.gd
@tool
extends Resource          # again – so it can be edited & saved if you want

class_name TaskQueue

# ------------------------------------------------------------------
# Public API
# ------------------------------------------------------------------

## Adds a task to the end of the queue.
func enqueue(quantity : int, source : NodePath, destination : NodePath, durSrc: float, durDst: float) -> void:
	var t = Task.new()
	t.id = UuidUtil.uuid()
	t.quantity = quantity
	t.source = source
	t.destination = destination
	t.durationDest = durDst
	t.durationSrc = durSrc
	_tasks.append(t)

## Removes & returns the first task in the queue. Returns null if empty.
func dequeue() -> Task:
	return _tasks.pop_front()

## When a task is partially picked up
func update_front(quantity : int, spoken : int) -> bool:
	if _tasks.is_empty():
		return false
	
	var t : Task = _tasks[0]          # Grab the first element
	t.quantity = quantity
	t.spoken = t.spoken + spoken
	return true

## When a building is destroyed, remove the existing tasks queued
func remove_by_node(node : NodePath) -> int:
	var removed : int = 0
	# We must iterate backwards so that removing items doesn’t shift indices we haven’t processed yet.
	for i in range(_tasks.size() - 1, -1, -1):
		var t : Task = _tasks[i]
		if t.source == node or t.destination == node:
			_tasks.remove_at(i)
			removed += 1

	return removed

## Peek at the first task without removing it, always check if empty
func peek() -> Task:
	return _tasks[0]

## Return true if the queue is currently empty.
func is_empty() -> bool: return _tasks.is_empty()

## Clear every queued task.
func clear() -> void: _tasks.clear()

## How many tasks are waiting?
func size() -> int: return _tasks.size()

# ------------------------------------------------------------------
# Optional “auto‑process” (useful for AI or game logic)
# ------------------------------------------------------------------

@export var auto_process : bool = false   # toggle in inspector
@export var process_interval : float = 0.5  # seconds between steps

var _time_accumulator : float = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if not auto_process or is_empty(): return
	_time_accumulator += delta
	if _time_accumulator >= process_interval:
		_time_accumulator -= process_interval
		_run_current_task()

## Hook‑in logic that runs each time a task is “completed”.
func _run_current_task() -> void:
	var t = dequeue()
	# --- YOUR CUSTOM CODE HERE ---
	# Example: print or move items between nodes.
	print("Processing %s" % [t])
	# You can also emit a signal if you want external listeners
	emit_signal("task_processed", t)

# ------------------------------------------------------------------
# Signals (optional)
# ------------------------------------------------------------------

signal task_processed(task : Task)   # emitted whenever _run_current_task() runs

# ------------------------------------------------------------------
# Private data
# ------------------------------------------------------------------
var _tasks : Array[Task] = []  # typed array for safety & editor hints
