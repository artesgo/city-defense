extends Button

@export var drill_down : String = ''

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the button press signal
	self.connect("pressed", Callable(self, '_on_pressed'))

func _on_pressed():
	# Show the HBoxRoad container when this button is pressed
	var parent = get_parent().get_parent()
	var hbox = parent.get_node(drill_down)
	if hbox:
		# Find last visible sibling other than hbox
		var last_open = null
		for child in parent.get_children():
			if child != hbox and child.visible:
				last_open = child
		# Hide all siblings except hbox and last_open
		for child in parent.get_children():
			if child != hbox and child != last_open:
				child.visible = false
		# Show the target HBoxRoad
		hbox.visible = !hbox.visible
