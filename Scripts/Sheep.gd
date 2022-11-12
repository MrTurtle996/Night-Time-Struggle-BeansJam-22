extends Area2D

func _ready():
	pass # Replace with function body.

func delete_sheep():
	var sheeps = Score.sheeps
	Score.sheeps = []
	for sheep in sheeps:
		if(sheep.position != position):
			Score.sheeps.append(sheep)
	
	self.queue_free()

func _on_Sheep_body_entered(body):
	if body.name != "Map":
		Score.collected_sheep = true
		delete_sheep()
