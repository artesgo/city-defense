# Create the curve for the underlying road
extends Path3D

class_name Road

func _process(delta) -> void:
	var curve = Curve3D.new()
	curve.add_point(Vector3(0, 0, 0))
	curve.add_point(Vector3(5, 0, 10))
	curve.add_point(Vector3(15, 0, 20))
	# … add as many points as you need

	var path = Path3D.new()
	path.curve = curve
	add_child(path)
