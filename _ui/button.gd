extends TextureButton

class_name MyTextureButton

@export var emitter : String = ''

signal click

func _ready():
	self.mouse_filter = Control.MOUSE_FILTER_STOP

func _button_pressed(event):
	print_debug('clicked' + emitter)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal('click', emitter)
