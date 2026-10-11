extends Node3D

class_name Road

var interval = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _straight(positions, lane_width: float, lane_height: float, material: StandardMaterial3D):
	var curve = Curve3D.new()
	var _p1 : Vector3 = positions.pop_front()
	var _p2 : Vector3 = positions.pop_front()
	curve.add_point(_p1)
	curve.add_point(_p2)
	var points = curve.get_baked_points()
	if points.size() < 2:
		return
	return _generate_mesh(points, lane_width, lane_height, material)

func _curve(positions, lane_width: float, lane_height: float, material: StandardMaterial3D):
	var curve = Curve3D.new()
	# Set baking interval before adding points to ensure interpolation
	curve.bake_interval = interval
	var _p1 : Vector3 = positions.pop_front()
	var _p2 : Vector3 = positions.pop_front()
	var _p3 : Vector3 = positions.pop_front()
	var in_handle = Vector3.ZERO
	var out_handle = Vector3.ZERO
	# ok google
	var alpha = 0.33
	var raw_tangent: Vector3 = _p3 - _p1
	var scaled_tangent: Vector3 = raw_tangent * alpha
	in_handle = -scaled_tangent
	out_handle = scaled_tangent
	# ok google end
	curve.add_point(_p1)
	curve.add_point(_p2, in_handle, out_handle)
	curve.add_point(_p3)
	# Generate simple road segments between points
	var points = curve.get_baked_points()
	if points.size() < 10:
		return
	return _generate_mesh(points, lane_width, lane_height, material)
	
func _generate_mesh(points, lane_width: float, lane_height: float, material: StandardMaterial3D):
	# Begin surface tool once before loop
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Add start cap before generating quad strip
	#var firstDir = (points[1] - points[0]).normalized()
	#_add_cap(st, points[0], firstDir, lane_width, false)
	# Generate vertices for a quad strip along the path
	var quads = []
	for i in range(points.size() - 1):
		var p0 = points[i]
		var p1 = points[i + 1]
		var dir = (p1 - p0).normalized()
		var up = Vector3.UP
		var right = dir.cross(up).normalized()
		# Apply vertical offset
		p0.y += lane_height
		p1.y += lane_height
		var half_lane = right * lane_width / 2.0
		var v0 = p0 - half_lane
		var v1 = p0 + half_lane
		var v2 = p1 - half_lane
		var v3 = p1 + half_lane
		quads.append({ "v0": v0, "v1": v1, "v2": v2, "v3": v3 })
	for i in range(quads.size() - 1):
		var q0 = quads[i]
		var q1 = quads[i + 1]
		# q0's 2 and 3 should be merged with q1's 0 and 1
		q0.v2 = (q0.v2 + q1.v0) / 2
		q1.v0 = q0.v2
		q0.v3 = (q0.v3 + q1.v1) / 2
		q1.v1 = q0.v3
		_add_quad(st, q0)
		# last quad
		if i == quads.size() - 1:
			_add_quad(st, q1)

	# Add end cap after generating quad strip
	#var lastDir = (points[points.size() - 1] - points[points.size() - 2]).normalized()
	#_add_cap(st, points[points.size() - 1], lastDir, lane_width, true)
	# Commit once after loop and create mesh instance
	var mesh = st.commit()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	return mesh_instance

func _add_quad(st: SurfaceTool, quad):
	st.add_vertex(quad.v0)
	st.add_vertex(quad.v2)
	st.add_vertex(quad.v3)
	# Second triangle
	st.add_vertex(quad.v0)
	st.add_vertex(quad.v3)
	st.add_vertex(quad.v1)
