extends TileMap

var last_pos
var tile_to_place = 9
var current_tile
var click_allowed

signal place_tile()
signal move_tile(placed_tile, tile_pos)

# Called when the node enters the scene tree for the first time.
func _ready():
	var _connect = get_node("../Map").connect("hovered_tile", self, "_on_emitter_hovered_tile")
	_connect = get_node("../Map").connect("tile_in_hand", self, "_on_emitter_tile_in_hand")
	_connect = self.connect("place_tile", self, "_on_emitter_place_tile")

func _unhandled_input(_event):
	if click_allowed && Input.is_action_just_pressed("mouse_click"):
		emit_signal("place_tile")

func _on_emitter_tile_in_hand(tile):
	tile_to_place = tile
	set_cellv(last_pos, tile_to_place)

func _on_emitter_place_tile():
	emit_signal("move_tile", tile_to_place, last_pos)

func _on_emitter_hovered_tile(tile_pos, hovered_tile):
	if last_pos != null:
			set_cellv(last_pos, -1)
	
	if hovered_tile != -1 && \
	   hovered_tile != 0 && \
	   hovered_tile != 1 && \
	   hovered_tile != 2 && \
	   hovered_tile != 3 && \
	   hovered_tile != 4:
		click_allowed = true
		current_tile = hovered_tile
		set_cellv(tile_pos, tile_to_place)
	else:
		click_allowed = false
		
	last_pos = tile_pos
