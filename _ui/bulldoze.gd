extends Button

signal bulldoze

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the button press signal
	self.connect("pressed", Callable(self, '_on_pressed'))

func _on_pressed():
	# Show the HBoxRoad container when this button is pressed
	bulldoze.emit(true)
