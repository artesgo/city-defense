extends CanvasLayer

# building, selecting, paused, 
var MODE = 'building'

signal escape_signal
signal click_signal
var menu_open = false

func _input(event):
	emit_escape(event)

func emit_escape(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			menu_open = !menu_open
			emit_signal("escape_signal", menu_open)

func _on_road_click(event):
	_emit_click(event)

func _on_zone_residential_click(event):
	_emit_click(event)

func _on_zone_commercial_click(event):
	_emit_click(event)

func _on_zone_industrial_click(event):
	_emit_click(event)

func _on_miner_click(event):
	_emit_click(event)

func _on_bulldozer_click(event):
	_emit_click(event)

func _emit_click(event):
	if event is InputEventMouseButton and event.pressed and MOUSE_BUTTON_LEFT:
		emit_signal('click_signal', event)
