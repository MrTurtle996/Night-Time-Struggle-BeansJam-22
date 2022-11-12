extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _pressed():
	Music.play_music()
	var _value = get_tree().change_scene("res://Scenes/Game.tscn")
