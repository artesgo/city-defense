extends Node

@onready var player : Navigator = $Character/CharacterBody3D
@onready var target : Building = $BUILDINGS/Building
@onready var target2 : Building = $BUILDINGS/Building2
var queue: TaskQueue = TaskQueue.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	queue.enqueue(10, target.get_path(), target2.get_path(), 2, 3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not queue.is_empty() and not player._moving:
		var task = queue.peek()
		player.assign(task)
