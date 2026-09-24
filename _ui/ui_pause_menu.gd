extends PanelContainer

func _ready() -> void:
	pass

func _on_ui_overlay_escape_signal(open):
	if (!open):
		hide()
	else:
		show()
