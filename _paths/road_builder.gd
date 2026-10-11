# RoadBuilder.gd
extends Node3D

class_name RoadBuilder

@export var camera : Camera3D = null          # Optional – will be auto‑found if left empty.
@onready var START  : MeshInstance3D = $Start
@onready var MIDWAY : MeshInstance3D = $Midway
@onready var END    : MeshInstance3D = $End

var active = true
signal construct_road(positions : PackedVector3Array)

# ------------------------------------------------------------------
# State
# ------------------------------------------------------------------
var menu_open = false                      # UI lock flag (e.g. while a dialog is open)
var click_positions : PackedVector3Array  = []   # Stores the three hit points

# For previewing
var _preview_line : ImmediateMesh          # Will be created in _ready()
var _highlighted_building : Node           = null
var _highlight_material : Material         # The “red” highlight

# ------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------
const SNAP_GRID_SIZE   := 1.0               # Snap to world grid of this size
const SNAP_ROAD_DIST   := 2.5               # Max distance from an existing road to snap
const BUILDING_LAYER   : int = 1 << 3        # Assuming buildings are on layer 4 (change if needed)

# ------------------------------------------------------------------
# _ready()
# ------------------------------------------------------------------
func _ready() -> void:
	# Hide markers until we get a click.
	START.visible  = true
	MIDWAY.visible = false
	END.visible    = false   # keep END visible for the preview line

	# Create the preview mesh once
	#_preview_line = ImmediateMesh.new()
	#var mat : StandardMaterial3D = StandardMaterial3D.new()
	#mat.albedo_color = Color(0.2, 0.8, 1.0)
	#_preview_line.material_override = mat

	# Grab the camera if not exported
	if camera == null:
		camera = get_viewport().get_camera_3d()
		assert(camera != null, "No Camera3D found – please assign one or add one to the scene.")

	# Load highlight material (you can create this in Godot and set the path)
	_highlight_material = preload("res://materials/deleting.tres")

# ------------------------------------------------------------------
# Input handling
# ------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if menu_open or !active:
		return

	# ----- 1️⃣ Left‑mouse click ------------------------------------
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var hit = _raycast_from_mouse(event.position)
		if hit:
			var point : Vector3 = hit.position
			point.y += 0.1  # raise a little above the ground

			# Snap logic
			#point = _snap_to_nearest_road(point) or _snap_to_grid(point)
			click_positions.append(point)
			match click_positions.size():
				1: _place_marker(START, point)
				2: _place_marker(MIDWAY, point)
				3: _place_end(END, point)

	# ----- 2️⃣ Right‑mouse click ------------------------------------
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_clear_points()
#C:/Users/Jinzo/Documents/planner
# ------------------------------------------------------------------
# Raycast helper
# ------------------------------------------------------------------
func _raycast_from_mouse(pos : Vector2) -> Dictionary:
	var from = camera.project_ray_origin(pos)
	var to   = from + camera.project_ray_normal(pos) * 1000.0

	var space_state = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.create(from, to)
	# Exclude the RoadBuilder node itself (so we can click on markers)
	params.exclude = [self]
	return space_state.intersect_ray(params)

# ------------------------------------------------------------------
# Marker placement helpers
# ------------------------------------------------------------------
func _place_marker(marker: MeshInstance3D, pos : Vector3) -> void:
	marker.global_transform.origin = pos
	marker.visible = true

func _place_end(marker: MeshInstance3D, pos : Vector3) -> void:
	_place_marker(marker, pos)
	_emit_points()

# ------------------------------------------------------------------
# Preview logic – called every frame
# ------------------------------------------------------------------
#func _process(_delta: float) -> void:
	#if click_positions.size() < 2:
		#return
#
	#var from = click_positions[-1]           # last placed point
	#var to   : Vector3 = _mouse_world_position()
	#if not to:
		#return
#
	## Highlight any building that the line would cross
	#_check_collision_with_buildings(from, to)
#
	## Draw preview line
	#_draw_preview_line(from, to)

# ------------------------------------------------------------------
# Get world position of mouse (for preview)
# ------------------------------------------------------------------
#func _mouse_world_position() -> Vector3:
	#var viewport = get_viewport()
	#if not viewport.has_mouse():
		#return null
	#var pos = viewport.get_mouse_position()
	#var hit = _raycast_from_mouse(pos)
	#if hit:
		#var p : Vector3 = hit.position
		#p.y += 0.1
		## Snap to grid or road for preview as well
		#p = _snap_to_nearest_road(p) or _snap_to_grid(p)
		#return p
	#return null

# ------------------------------------------------------------------
# Drawing the line with ImmediateMesh
# ------------------------------------------------------------------
func _draw_preview_line(a : Vector3, b : Vector3) -> void:
	var mesh_instance = get_node_or_null("PreviewLine")
	if not mesh_instance:
		# Create a child node to hold the preview mesh once
		mesh_instance = MeshInstance3D.new()
		mesh_instance.name = "PreviewLine"
		add_child(mesh_instance)
	mesh_instance.mesh = _preview_line

	var _arr = ArrayMesh.new()
	var verts : PackedVector3Array = [a, b]
	var _indices : PackedInt32Array = [0, 1]

	# Build the immediate mesh
	_preview_line.clear_surfaces()
	_preview_line.surface_begin(Mesh.PRIMITIVE_LINES)
	for v in verts:
		_preview_line.surface_set_color(Color(0.2, 0.8, 1.0))
		_preview_line.surface_add_vertex(v)
	_preview_line.surface_end()

# ------------------------------------------------------------------
# Snap helpers
# ------------------------------------------------------------------
func _snap_to_grid(p : Vector3) -> Vector3:
	return p.snapped(Vector3(SNAP_GRID_SIZE, SNAP_GRID_SIZE, SNAP_GRID_SIZE))

#func _snap_to_nearest_road(p : Vector3):
	## This is a very naive example – you can replace it with NavigationServer
	## or a spatial hash of road segments.
	#var nearest = null
	#var min_dist = INF
#
	#for child in get_parent().get_children():
		#if child == self: continue
		#if not child.is_in_group("RoadSegment"):  # only look at roads
			#continue
		#var seg : RoadSegment = child as RoadSegment
		#var dist = seg.distance_to_point(p)
		#if dist < min_dist and dist <= SNAP_ROAD_DIST:
			#min_dist = dist
			#nearest = seg.get_closest_point(p)
#
	#return nearest

# ------------------------------------------------------------------
# Building collision & highlight
# ------------------------------------------------------------------
func _check_collision_with_buildings(a : Vector3, b : Vector3) -> void:
	var space_state = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.create(a, b)
	params.collision_mask = BUILDING_LAYER

	var result = space_state.intersect_ray(params)
	if result and result.collider:
		var building : Node = result.collider.get_parent()  # assume the collider is a child of the building node
		if building != _highlighted_building:
			_remove_highlight()
			_apply_highlight(building)
	else:
		_remove_highlight()

func _apply_highlight(node : Node) -> void:
	if not node: return
	var mesh = node.get_node_or_null("MeshInstance3D")
	if mesh and mesh.material_override == null:
		mesh.material_override = _highlight_material
		_highlighted_building = node

func _remove_highlight() -> void:
	if _highlighted_building:
		var mesh = _highlighted_building.get_node_or_null("MeshInstance3D")
		if mesh: mesh.material_override = null
		_highlighted_building = null

# ------------------------------------------------------------------
# Final road creation (after 3 points)
# ------------------------------------------------------------------
func _emit_points() -> void:
	# Send the positions to anyone listening – e.g. a RoadManager
	emit_signal("construct_road", [START.global_position, MIDWAY.global_position, END.global_position])

	# Optionally auto‑spawn road segments
	#_create_road_segments()

	_clear_points()

func _create_road_segments() -> void:
	var positions : PackedVector3Array = [START.global_position, MIDWAY.global_position, END.global_position]
	for i in range(positions.size() - 1):
		var seg_scene = preload("res://_paths/RoadSegment.tscn")
		var segment : Node3D = seg_scene.instantiate()
		add_child(segment)
		segment.position = positions[i]

		# Simple orientation – assumes the road is a straight cylinder
		var _dir = (positions[i+1] - positions[i]).normalized()
		segment.look_at(positions[i+1], Vector3.UP)

# ------------------------------------------------------------------
# UI callbacks / menu lock
# ------------------------------------------------------------------
func _on_node_root_menu_open(event):
	menu_open = event

# ------------------------------------------------------------------
# Clearing all points & markers
# ------------------------------------------------------------------
func _clear_points() -> void:
	click_positions.clear()
	START.visible  = false
	MIDWAY.visible = false
	END.visible    = false
	_remove_highlight()

# TODO: block points that are too close together
