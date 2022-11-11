extends TileMap

export var playAreaSize : Vector2

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
	_GenerateMap()
	playAreaSize.x += 2
	playAreaSize.y += 2
	_PlaceTiles()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _GenerateMap():
	for x in (playAreaSize.x):
		for y in (playAreaSize.y):
			set_cell(x + 1, y + 1, 0)
	pass

func _PlaceTiles():
	for x in playAreaSize.x:
		for y in playAreaSize.y:
			if (x == 0 && y == 0) || \
			   (x == playAreaSize.x - 1 && y == playAreaSize.y - 1) || \
			   (x == playAreaSize.x - 1 && y == 0) || \
			   (x == 0 && y == playAreaSize.y - 1): 
				continue
			elif x == 0:
				if _AllowTilePlace(Vector2(x, y), _Position.Left): set_cell(x, y, _PlaceTiles.Left)
				else: set_cell(x, y, _BlockTiles.Left)
			elif x == playAreaSize.x - 1:
				if _AllowTilePlace(Vector2(x, y), _Position.Right): set_cell(x, y, _PlaceTiles.Right)
				else: set_cell(x, y, _BlockTiles.Right)
			elif y == 0:
				if _AllowTilePlace(Vector2(x, y), _Position.Top): set_cell(x, y, _PlaceTiles.Top)
				else: set_cell(x, y, _BlockTiles.Top)
			elif y == playAreaSize.y - 1:
				if _AllowTilePlace(Vector2(x, y), _Position.Bottom): set_cell(x, y, _PlaceTiles.Bottom)
				else: set_cell(x, y, _BlockTiles.Bottom)
				
func _AllowTilePlace(position, pEnum):
	match pEnum:
		_Position.Top:
			position.y = playAreaSize.y - 2
		_Position.Right:
			position.x = 1
		_Position.Bottom:
			position.y = 1
		_Position.Left:
			position.x = playAreaSize.x - 2
			
	var cell = get_cell(position.x, position.y)
	if cell == 0: return true
	
	return false
