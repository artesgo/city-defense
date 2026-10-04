extends Node3D

# OnRoadBuilder, add child road

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#TODO: 

func _on_road_builder_construct_road(positions):
	print_debug('road listener received')
	print_debug(positions)

#TODO: when roads are built, make plots next to road buildable
