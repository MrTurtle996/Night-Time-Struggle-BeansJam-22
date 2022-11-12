extends AudioStreamPlayer


var music = load("res://Sounds/8bit-dreaming.ogg")
var game_over = load("res://Sounds/gameover.wav")

func _ready():
	pass # Replace with function body.
	
func play_music():
	stream = music
	play()

func play_gameover():
	stream = game_over
	play()
