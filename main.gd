extends Node3D

#@onready var escape_signal = get_node("Ui/UIOverlay")
#@onready var click_signal = get_node("Ui/UIOverlay")

signal menu_open
# Called when the node enters the scene tree for the first time.
func _ready():
	#escape_signal.connect('escape_signal', Callable(self, '_on_escape'))
	#click_signal.connect('click_signal', Callable(self, '_on_click'))
	var viewport := get_viewport()
	viewport.debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	#pass

func _on_escape(open):
	#emit_signal('menu_open', open)
	pass

func _on_click(event):
	print_debug(event)
	print_debug('clicked')
