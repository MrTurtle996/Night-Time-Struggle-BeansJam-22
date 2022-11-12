extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func delete_drink():
	var drinks = Score.drinks
	Score.drinks = []
	for drink in drinks:
		if(drink.position != position):
			Score.drinks.append(drink)
	
	self.queue_free()

func _on_Drink_body_entered(body):
	if body.name == "Inventory":
		Score.item = "Coffee"

	elif body.name != "Map":
		Score.collected_coffee = true
	
	delete_drink()
