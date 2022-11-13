extends Area2D

var set_active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func delete_drink():
	var drinks = Score.drinks
	Score.drinks = []
	for drink in drinks:
		if(drink.position != position):
			Score.drinks.append(drink)
	
	self.queue_free()

func _on_Drink_body_entered(body):
	if !set_active: return
	
	if body.name == "Inventory":
		Score.item = "Coffee"
		delete_drink()

	elif body.name == "Character":
		Score.collected_coffee = true
		delete_drink()
	


func _on_Timer_timeout():
	set_active = true
