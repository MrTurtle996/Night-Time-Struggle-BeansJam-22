extends Sprite

export var goal : Vector2

var startup = true;

signal goal_position(pos)

# Called when the node enters the scene tree for the first time.
func _ready():
	position = goal
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if startup:
		startup = false
		emit_signal("goal_position", goal)
