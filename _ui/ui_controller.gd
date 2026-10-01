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

func _emit_click(event):
	emit_signal('click_signal', event)

func _on_road_pressed():
	_emit_click('build_road')

func _on_zone_residential_pressed():
	_emit_click('build_residential')

func _on_zone_commercial_pressed():
	_emit_click('build_commercial')

func _on_zone_industrial_pressed():
	_emit_click('build_industrial')

func _on_mine_pressed():
	_emit_click('build_mine')

func _on_bulldozer_pressed():
	_emit_click('build_dozer')
