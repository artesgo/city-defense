extends Sprite3D

class_name HP_BAR

var max_hp: int
var current = 0

func _ready():
	max_hp = get_parent().hp
	current = max_hp

func _on_enemy_take_dmg_signal(dmg):
	current -= dmg
	print_debug(current)
	pass # Replace with function body.
