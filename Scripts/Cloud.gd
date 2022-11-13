extends Sprite


export var start: Vector2
export var end: Vector2
export var speed: float

var toPos

# Called when the node enters the scene tree for the first time.
func _ready():
	toPos = start

func _process(delta):
	if(position == toPos):
		if toPos == start:
			toPos = end
		else:
			toPos = start
	
	if position != toPos:
		position = position.move_toward(toPos, delta * speed)
