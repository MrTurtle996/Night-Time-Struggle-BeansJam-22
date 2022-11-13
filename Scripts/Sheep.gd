extends Area2D

var set_active = false

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
	if !set_active: return
	
	if body.name != "Map":
		Score.collected_sheep = true
		delete_sheep()


func _on_Timer_timeout():
	set_active = true
