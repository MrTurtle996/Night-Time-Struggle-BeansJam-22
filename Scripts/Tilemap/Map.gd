extends TileMap

export var play_area_size : Vector2

signal hovered_tile(tile_pos, tile)
signal tile_in_hand(tile, flip_x, flip_y, transpose)

var startup = true
var _last_hovered_tile = -1
var _last_hovered_pos

var drinkScene
var sheepScene

var player_pos
var goal_pos

enum _Position {
	Top,
	Right,
	Bottom,
	Left,
}

enum _Maptiles {
	Corner = 10,
	Cross = 11,
	OnePath = 12,
	Straight = 13,
	TPath = 14
}

enum _PlaceTiles {
	Top = 6,
	Right = 8,
	Bottom = 5,
	Left = 7
}

enum _BlockTiles {
	Top = 2,
	Right = 4,
	Bottom = 1,
	Left = 3
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var _connect = get_node("../Hover").connect("move_tile", self, "_on_emitter_move_tile")
	_connect = get_node("../Character").connect("player_position", self, "_on_emitter_player_position")
	_connect = get_node("../Character").connect("has_new_position", self, "_on_emitter_has_new_position")
	
	drinkScene = ResourceLoader.load("res://Prefabs/Drink.tscn")
	sheepScene = ResourceLoader.load("res://Prefabs/Sheep.tscn")
	
	Score.item = ""
	Score.score = 0
	Score.collected_coffee = false
	Score.won = false
	Score.drinks = []
	Score.sheeps = []
	
	_start_pos()
	_goal_pos()
	_generate_map()
	play_area_size.x += 2
	play_area_size.y += 2
	_place_tiles()

func _process(_delta):
	if startup:
		emit_signal("tile_in_hand", 10 + randi() % 5, false, false, false)
		startup = false

func _generate_map():
	for x in (play_area_size.x):
		for y in (play_area_size.y):
			var rand_tile = 10 + randi() % 5
			var rand_flip_x = randi() % 2
			var rand_flip_y = randi() % 2
			var rand_transpose = randi() % 2
			set_cell(x + 1, y + 1, rand_tile,rand_flip_x, rand_flip_y, rand_transpose)
			
			if Vector2(x + 1, y + 1) != world_to_map(get_node("../Character").position):
				var possibility = randi() % 100
				if possibility < 20:
					var drink = drinkScene.instance()
					drink.position = map_to_world(Vector2(x + 1, y + 1))
					drink.position.x += 32
					drink.position.y += 32
					get_node("../Energy").add_child(drink)
					Score.drinks.append(drink)
				if(possibility >= 80):
					var sheep = sheepScene.instance()
					sheep.position = map_to_world(Vector2(x + 1, y + 1))
					sheep.position.x += 32
					sheep.position.y += 32
					get_node("../Enemy").add_child(sheep)
					Score.sheeps.append(sheep)

func _start_pos():
	var rand_x = 1 + randi() % int(play_area_size.x)
	var rand_y = 1 + randi() % int(play_area_size.y)
	var pos = map_to_world(Vector2(rand_x, rand_y))
	get_node("../Character").position = Vector2(pos.x + 32, pos.y + 25)

func _goal_pos():
	var rand_x = 1 + randi() % int(play_area_size.x)
	var rand_y = 1 + randi() % int(play_area_size.y)
	var pos = map_to_world(Vector2(rand_x, rand_y))
	get_node("../Goal").position = Vector2(pos.x + 32, pos.y + 25)

func _place_tiles():
	for x in play_area_size.x:
		for y in play_area_size.y:
			if (x == 0 && y == 0) || \
			   (x == play_area_size.x - 1 && y == play_area_size.y - 1) || \
			   (x == play_area_size.x - 1 && y == 0) || \
			   (x == 0 && y == play_area_size.y - 1): 
				continue
			elif x == 0:
				if _allow_tile_place(Vector2(x, y), _Position.Left): set_cell(x, y, _PlaceTiles.Left)
				else: set_cell(x, y, _BlockTiles.Left)
			elif x == play_area_size.x - 1:
				if _allow_tile_place(Vector2(x, y), _Position.Right): set_cell(x, y, _PlaceTiles.Right)
				else: set_cell(x, y, _BlockTiles.Right)
			elif y == 0:
				if _allow_tile_place(Vector2(x, y), _Position.Top): set_cell(x, y, _PlaceTiles.Top)
				else: set_cell(x, y, _BlockTiles.Top)
			elif y == play_area_size.y - 1:
				if _allow_tile_place(Vector2(x, y), _Position.Bottom): set_cell(x, y, _PlaceTiles.Bottom)
				else: set_cell(x, y, _BlockTiles.Bottom)
				
func _allow_tile_place(position, pEnum):
	match pEnum:
		_Position.Top:
			position.y = play_area_size.y - 2
		_Position.Right:
			position.x = 1
		_Position.Bottom:
			position.y = 1
		_Position.Left:
			position.x = play_area_size.x - 2
	
	for sheep in Score.sheeps:
		if sheep != null:
			if position == world_to_map(sheep.position):
				return false
	
	if position != world_to_map(get_node("../Character").position) && position != world_to_map(get_node("../Goal").position):
		return true
	
	return false

func _get_hovered_tile():
	var mouse_pos = get_viewport().get_mouse_position()
	var tile_pos = world_to_map(mouse_pos)
	var tile_at_pos = get_cellv(tile_pos)
	
	emit_signal("hovered_tile", tile_pos, tile_at_pos)

func _move_tile(start, tile, on_x_axis, positive, flip_x, flip_y, transpose):
	var loop = 0
	var increment = +1
	var tFlip_x = flip_x
	var tFlip_y = flip_y
	var tTranspose = transpose
	player_pos = get_node("../Character").position
	goal_pos = get_node("../Goal").position
	var sheep_pos = []
	for sheep in Score.sheeps:
		sheep_pos.append(world_to_map(sheep.position))
	var drink_pos = []
	for drink in Score.drinks:
		drink_pos.append(world_to_map(drink.position))
	
	if on_x_axis: loop = play_area_size.x - 2
	else: loop = play_area_size.y - 2
	
	if !positive: increment = -1
	
	var item_pos = start
	if on_x_axis:
		item_pos.x += increment
	else:
		item_pos.y += increment
	
	for i in loop:
		if on_x_axis:
			start.x += increment
		else:
			start.y += increment
		
		var next_tile = get_cellv(start)
		var next_flip_x = is_cell_x_flipped(start.x, start.y)
		var next_flip_y = is_cell_y_flipped(start.x, start.y)
		var next_transpose = is_cell_transposed(start.x, start.y)
		var sheep_index = 0
		for sheep in Score.sheeps:
			if start == sheep_pos[sheep_index]:
				if on_x_axis:
					sheep.position.x += increment * 64
				else:
					sheep.position.y += increment * 64
			sheep_index += 1
		var drink_index = 0
		for drink in Score.drinks:
			if start == drink_pos[drink_index]:
				if on_x_axis:
					drink.position.x += increment * 64
				else:
					drink.position.y += increment * 64
			drink_index += 1
		if(start == world_to_map(goal_pos)):
			if on_x_axis:
				get_node("../Goal").position.x += increment * 64
			else:
				get_node("../Goal").position.y += increment * 64
		if start == world_to_map(player_pos):
			if on_x_axis:
				get_node("../Character").position.x += increment * 64
			else:
				get_node("../Character").position.y += increment * 64
		set_cellv(start, tile, tFlip_x, tFlip_y, tTranspose)
		tile = next_tile
		tFlip_x = next_flip_x
		tFlip_y = next_flip_y
		tTranspose = next_transpose
		
	if Score.item != "":
		match Score.item:
			"Coffee":
				var new_drink = drinkScene.instance()
				new_drink.position = map_to_world(Vector2(item_pos))
				new_drink.position.x += 32
				new_drink.position.y += 32
				get_node("../Energy").add_child(new_drink)
				Score.drinks.append(new_drink)
				drink_pos.append(world_to_map(new_drink.position))
			"Sheep":
				var new_sheep = sheepScene.instance()
				new_sheep.position = map_to_world(Vector2(item_pos))
				new_sheep.position.x += 32
				new_sheep.position.y += 32
				get_node("../Enemy").add_child(new_sheep)
				Score.sheeps.append(new_sheep)
				sheep_pos.append(world_to_map(new_sheep.position))
		Score.item = ""
	
	_place_tiles()
	var new_drink_possibility = randi() % 100
	if Score.item == "" && new_drink_possibility < 30:
		Score.item = "Coffee"
	if Score.item == "":
		var new_sheep_possibility = randi() % 100
		if new_sheep_possibility < 100:
			Score.item = "Sheep"
	emit_signal("tile_in_hand", tile, tFlip_x, tFlip_y, tTranspose)

func _on_emitter_player_position(pos):
	player_pos = pos

func _on_emitter_goal_position(pos):
	goal_pos = pos

func _on_emitter_move_tile(placed_tile, tile_pos, flip_x, flip_y, transpose):
	if tile_pos.x == 0:
		_move_tile(tile_pos, placed_tile, true, true, flip_x, flip_y, transpose)
	elif tile_pos.x == play_area_size.x - 1:
		_move_tile(tile_pos, placed_tile, true, false, flip_x, flip_y, transpose)
	elif tile_pos.y == 0:
		_move_tile(tile_pos, placed_tile, false, true, flip_x, flip_y, transpose)
	elif tile_pos.y == play_area_size.y - 1:
		_move_tile(tile_pos, placed_tile, false, false, flip_x, flip_y, transpose)

func _on_emitter_has_new_position():
	_place_tiles()

func _unhandled_input(_event):
	if !startup:
		_get_hovered_tile()
