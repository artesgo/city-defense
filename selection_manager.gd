extends Node3D

var _selected_nodes: Array[Node] = []
@export var camera : Camera3D = null          # Optional – will be auto‑found if left empty.

# Called when the node enters the scene tree for the first time.
func _ready():
		# Grab the camera if not exported
	if camera == null:
		camera = get_viewport().get_camera_3d()
		assert(camera != null, "No Camera3D found – please assign one or add one to the scene.")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and \
	   event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

		var mouse_pos: Vector2 = event.position
		_handle_left_click(mouse_pos)

func _handle_left_click(mouse_pos: Vector2) -> void:
	var origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var direction: Vector3 = camera.project_ray_normal(mouse_pos)
	var to: Vector3 = origin + direction * 1000.0   # arbitrary long distance

	var space_state = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.create(origin, to)
	params.exclude = [self]
	var result = space_state.intersect_ray(params)

	if result:
		print_debug(result)
		var collider: Node3D = result.collider as Node3D
		# Make sure it really is selectable (safety check)
		if "selectable" in collider.get_groups():
			_clear_selection()
			_add_selected(collider)
			return   # finished – a node was selected

	# 3. If we got here, nothing selectable was hit → deselect everything
	_clear_selection()

func _add_selected(node: Node) -> void:
	if node in _selected_nodes: return
	_selected_nodes.append(node)
	node.call("select")

func _clear_selection() -> void:
	for n in _selected_nodes:
		n.call("deselect")
	_selected_nodes.clear()
