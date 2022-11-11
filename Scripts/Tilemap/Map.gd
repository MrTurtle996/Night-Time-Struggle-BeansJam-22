extends TileMap

export var play_area_size : Vector2

signal hovered_tile(tile_pos, tile)
signal tile_in_hand(tile)

var _last_hovered_tile = -1
var _last_hovered_pos

enum _Position {
	Top,
	Right,
	Bottom,
	Left,
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
	
	_generate_map()
	play_area_size.x += 2
	play_area_size.y += 2
	_place_tiles()

func _generate_map():
	for x in (play_area_size.x):
		for y in (play_area_size.y):
			set_cell(x + 1, y + 1, 0)

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
	if cell == 0: return true
	
	return false

func _get_hovered_tile():
	var mouse_pos = get_viewport().get_mouse_position()
	var tile_pos = world_to_map(mouse_pos)
	var tile_at_pos = get_cellv(tile_pos)
	
	emit_signal("hovered_tile", tile_pos, tile_at_pos)

func _move_tile(start, tile, on_x_axis, positive):
	var loop = 0
	var increment = +1
	
	if on_x_axis: loop = play_area_size.x - 2
	else: loop = play_area_size.y - 2
	
	if !positive: increment = -1
	
	for i in loop:
		if on_x_axis:
			start.x += increment
		else:
			start.y += increment
		
		var next_tile = get_cellv(start)
		set_cellv(start, tile)
		tile = next_tile
	
	_place_tiles()
	_get_hovered_tile()
	emit_signal("tile_in_hand", tile)

func _on_emitter_move_tile(placed_tile, tile_pos):
	if tile_pos.x == 0:
		_move_tile(tile_pos, placed_tile, true, true)
	elif tile_pos.x == play_area_size.x - 1:
		_move_tile(tile_pos, placed_tile, true, false)
	elif tile_pos.y == 0:
		_move_tile(tile_pos, placed_tile, false, true)
	elif tile_pos.y == play_area_size.y - 1:
		_move_tile(tile_pos, placed_tile, false, false)

func _unhandled_input(_event):
	_get_hovered_tile()
