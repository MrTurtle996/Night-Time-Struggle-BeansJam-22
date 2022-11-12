extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	self.text = str(get_node("../SleepBar").score)
