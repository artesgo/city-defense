extends Node3D

# OnRoadBuilder, add child road

# Called when the node enters the scene tree for the first time.
var road_curve : Curve3D = null

func _ready():
	# Create ImmediateGeometry for debug drawing
	#var ig = ImmediateMesh.new()
	#add_child(ig)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

#TODO: build straight road
func _on_build_straight_road(lanes: int):
	pass

func _on_build_straight_oneway(lanes: int):
	pass

#TODO: build curved road on 3 selections
func _on_road_builder_construct_road(positions):
	var curve = Curve3D.new()
	# Set baking interval before adding points to ensure interpolation
	curve.bake_interval = 1.0
	var _p1 : Vector3 = positions.pop_front()
	var _p2 : Vector3 = positions.pop_front()
	var _p3 : Vector3 = positions.pop_front()
	var in_handle = Vector3.ZERO
	var out_handle = Vector3.ZERO
	# ok google
	var alpha = 0.33
	var raw_tangent: Vector3 = _p3 - _p1
	var scaled_tangent: Vector3 = raw_tangent * alpha
	#in_handle = _p2 - (alpha * (_p3 - _p1))
	#out_handle = _p2 + (alpha * (_p3 - _p1))
	in_handle = -scaled_tangent
	out_handle = scaled_tangent
	# ok google end
	curve.add_point(_p1)
	curve.add_point(_p2, in_handle, out_handle)
	curve.add_point(_p3)
	# Generate simple road segments between points
	var lane_width = 1.0
	var road_height = 0.01
	var points = curve.get_baked_points()
	if points.size() < 2:
		return
	# Begin surface tool once before loop
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Generate vertices for a quad strip along the path
	for i in range(points.size() - 1):
		var p0 = points[i]
		var p1 = points[i + 1]
		var dir = (p1 - p0).normalized()
		var up = Vector3.UP
		var right = dir.cross(up).normalized()
		# Apply vertical offset
		p0.y += road_height
		p1.y += road_height
		var v0 = p0 - right * lane_width / 2.0
		var v1 = p0 + right * lane_width / 2.0
		var v2 = p1 - right * lane_width / 2.0
		var v3 = p1 + right * lane_width / 2.0
		# First triangle
		st.add_vertex(v0)
		st.add_vertex(v2)
		st.add_vertex(v3)
		# Second triangle
		st.add_vertex(v0)
		st.add_vertex(v3)
		st.add_vertex(v1)
	# Commit once after loop and create mesh instance
	var mesh = st.commit()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	var mat = StandardMaterial3D.new();
	mat.albedo_color = Color(0.4, 0.2, 0.1)
	mesh_instance.material_override = mat
	add_child(mesh_instance)
