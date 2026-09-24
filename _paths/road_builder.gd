extends Node3D

class_name RoadBuilder

@export var cam : Camera3D = null

@onready var START : MeshInstance3D = $Start
@onready var MIDWAY : MeshInstance3D = $Midway
@onready var END : MeshInstance3D = $End
signal construct_road

var menu_open = false
var click_positions : PackedVector3Array = []   # stores the three hit points

func _ready() -> void:
	# Hide everything until we get a click.
	START.visible  = false
	MIDWAY.visible = false
	END.visible    = false

	# If you didn't export a camera, grab the first one in the scene tree.
	if cam == null:
		cam = get_viewport().get_camera_3d()
		assert(cam != null, "No Camera3D found – please assign one or add one to the scene.")

func _input(event: InputEvent) -> void:
	if menu_open:
		return
	# ---- 1️⃣ Handle left‑mouse click ------------------------------------
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var from = cam.project_ray_origin(event.position)
		var to = from + cam.project_ray_normal(event.position) * 1000.0

		# Raycast against everything except this node itself (so you can click on the markers).
		var space_state = get_world_3d().direct_space_state
		var ray = PhysicsRayQueryParameters3D.create(from, to) 
		var result = space_state.intersect_ray(ray)

		if result:
			var hit_point : Vector3 = result.position
			hit_point.y += 0.1
			click_positions.append(hit_point)
			match click_positions.size():
				1: _place_marker(START, hit_point)
				2: _place_marker(MIDWAY, hit_point)
				3: _place_end(END, hit_point)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_clear_points()


## ------------------------------
func _place_marker(marker: MeshInstance3D, _position: Vector3) -> void:
	marker.global_transform.origin = _position
	marker.visible = true

func _place_end(marker: MeshInstance3D, _position: Vector3) -> void:
	_place_marker(marker, _position)
	_emit_points()

func _on_node_root_menu_open(event):
	menu_open = event

func _emit_points():
	emit_signal('construct_road', [START.global_position, MIDWAY.global_position, END.global_position])
	_clear_points()

func _clear_points():
	click_positions.clear()
	START.visible  = false
	MIDWAY.visible = false
	END.visible    = false
