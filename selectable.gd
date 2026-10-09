extends Node3D

class_name SelectableNode

static var current_selected : SelectableNode = null

@export var selection_size := 1
@onready var SELECTION  : MeshInstance3D = $Selection

var is_selected : bool = false

func _select_self() -> void:
	# If *another* node was selected, ask it to un‑select itself.
	if current_selected and current_selected != self:
		current_selected._deselect()

	# Register this instance as the new “current” selection.
	current_selected = self

	# Mark ourselves as selected.
	is_selected = true
	if SELECTION:
		SELECTION.visible = true

func _deselect():
	is_selected = false
	if SELECTION:
		SELECTION.visible = false

func _input_event(_camera, event, _event_position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_self()
