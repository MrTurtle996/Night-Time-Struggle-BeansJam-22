extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if Score.won:
		self.text = "Gut das ein Bett in der Naehe war"
		self.add_color_override("font_color", Color.green)
	else:
		self.text = "Leider war kein Bett in deiner Naehe"
		self.add_color_override("font_color", Color.red)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
