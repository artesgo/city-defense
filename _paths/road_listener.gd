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
func _on_build_straight_road(positions):
	var road = Road.new()
	var mat = StandardMaterial3D.new();
	mat.albedo_color = Color(0.4, 0.2, 0.1)
	var mesh = road._straight(positions, 2.0, 0.01, mat)
	add_child(mesh)

func _on_build_straight_oneway(positions):
	var road = Road.new()
	var mat = StandardMaterial3D.new();
	mat.albedo_color = Color(0.4, 0.2, 0.1)
	var mesh = road._straight(positions, 2.0, 0.01, mat)
	add_child(mesh)

#TODO: build curved road on 3 selections
func _on_road_builder_construct_road(positions):
	var road = Road.new()
	var mat = StandardMaterial3D.new();
	mat.albedo_color = Color(0.4, 0.2, 0.1)
	var mesh = road._curve(positions, 2.0, 0.01, mat)
	add_child(mesh)

# Helper to add semicircle cap
func _add_cap(st: SurfaceTool, center: Vector3, dir: Vector3, lane_width: float, reverse: bool = false):
	const segments = 12
	var radius = lane_width / 2.0
	var right = dir.cross(Vector3.UP).normalized()
	var binorm = Vector3.UP.cross(dir).normalized()
	for i in range(segments):
		var t1 = float(i) / segments * PI
		var t2 = float(i + 1) / segments * PI
		if reverse:
			t1 += PI
			t2 += PI
		var p1 = center + (right * cos(t1) + binorm * sin(t1)) * radius
		var p2 = center + (right * cos(t2) + binorm * sin(t2)) * radius
		st.add_vertex(center)
		st.add_vertex(p1)
		st.add_vertex(p2)
