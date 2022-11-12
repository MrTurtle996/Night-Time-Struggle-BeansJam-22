extends TileMap

export var play_area_size : Vector2

signal hovered_tile(tile_pos, tile)
signal tile_in_hand(tile, flip_x, flip_y, transpose)

var startup = true
var _last_hovered_tile = -1
var _last_hovered_pos

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
	_connect = get_node("../Goal").connect("goal_position", self, "_on_emitter_goal_position")
	
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
			var rand = 10 + randi() % 5
			set_cell(x + 1, y + 1, rand)

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
			
	var cell = get_cellv(position)
	if cell != -1: return true
	
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
	
	if on_x_axis: loop = play_area_size.x - 2
	else: loop = play_area_size.y - 2
	
	if !positive: increment = -1
	
	for i in loop:
		if on_x_axis:
			start.x += increment
		else:
			start.y += increment
		
		var next_tile = get_cellv(start)
		var next_flip_x = is_cell_x_flipped(start.x, start.y)
		var next_flip_y = is_cell_y_flipped(start.x, start.y)
		var next_transpose = is_cell_transposed(start.x, start.y)
		if(start == world_to_map(player_pos)):
			if on_x_axis:
				get_node("../Character").position.x += increment * 64
			else:
				get_node("../Character").position.y += increment * 64
		if(start == world_to_map(goal_pos)):
			if on_x_axis:
				get_node("../Goal").position.x += increment * 64
				get_node("../Goal").goal = position
			else:
				get_node("../Goal").position.y += increment * 64
				get_node("../Goal").goal = position
		set_cellv(start, tile, tFlip_x, tFlip_y, tTranspose)
		tile = next_tile
		tFlip_x = next_flip_x
		tFlip_y = next_flip_y
		tTranspose = next_transpose
	
	_place_tiles()
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

func _unhandled_input(_event):
	if !startup:
		_get_hovered_tile()
