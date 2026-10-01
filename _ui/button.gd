extends Button

class_name UiButton

func _ready():
	self.mouse_filter = Control.MOUSE_FILTER_STOP

## ------------------------------------------------------------------
## 2. Intercept & handle the click yourself
## ------------------------------------------------------------------
func _gui_input(event: InputEvent) -> void:
	# Only care about mouse button / touch events that are pressed
	if event is InputEventMouseButton and event.pressed:
		# Do whatever you want here.
		print("[InterceptButton] Click detected on %s" % name)

		# In Godot 4.x: mark the event as handled so nobody else sees it
		# (the MOUSE_FILTER_STOP already stops bubbling, but this is a safety net)
		if has_method("set_handled"):     # Godot 4.x method
			event.set_handled()
		else:                             # Godot 3.x – use accept_event()
			accept_event()

	# If you also want to handle touch events on mobile:
	elif event is InputEventScreenTouch and event.pressed:
		print("[InterceptButton] Touch detected")
		if has_method("set_handled"):
			event.set_handled()
		else:
			accept_event()
			
## ------------------------------------------------------------------
## 3. Optional: expose a signal so other code can react
## ------------------------------------------------------------------
signal clicked

func _on_pressed() -> void:
	# This signal is emitted by Button after it processes the click.
	emit_signal("clicked")
