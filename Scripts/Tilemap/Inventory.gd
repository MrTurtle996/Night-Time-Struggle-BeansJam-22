extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var _connect = get_node("../../Map").connect("tile_in_hand", self, "_on_emitter_tile_in_hand")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(Score.item == "Coffee"):
		get_node("../Extra/Sprite").texture = load("res://Sprites/Drink.png")
	if(Score.item == "Sheep"):
		get_node("../Extra/Sprite").texture = load("res://Sprites/Sheep.png")
	if(Score.item == ""):
		get_node("../Extra/Sprite").texture = null
	pass

func _on_emitter_tile_in_hand(tile, _flip_x, _flip_y, _transpose):
	set_cell(14, 7, tile)
