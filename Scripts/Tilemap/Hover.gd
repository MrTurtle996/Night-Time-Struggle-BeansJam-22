extends TileMap

var last_pos
var tile_to_place
var current_tile
var click_allowed
var rotate_tile = 0

var flip_x = false
var flip_y = false
var transpose = false

var player_is_moving = false

signal place_tile()
signal move_tile(placed_tile, tile_pos, flip_x, flip_y, transpose)

# Called when the node enters the scene tree for the first time.
func _ready():
	var _connect = get_node("../Map").connect("tile_in_hand", self, "_on_emitter_tile_in_hand")
	_connect = get_node("../Map").connect("hovered_tile", self, "_on_emitter_hovered_tile")
	_connect = get_node("../Character").connect("player_is_moving", self, "_on_emitter_player_is_moving")
	_connect = self.connect("place_tile", self, "_on_emitter_place_tile")

func _unhandled_input(_event):
	if click_allowed && !player_is_moving && Input.is_action_just_pressed("mouse_click"):
		get_node("../PlaceMusic").play()
		emit_signal("place_tile")
	if click_allowed && Input.is_action_just_pressed("mouse_click_right"):
		get_node("../PlaceMusic").play()
		_rotate_tile()

func _rotate_tile():
	if(!flip_x && !flip_y && !transpose): rotate_tile = 0
	if(flip_x && !flip_y && transpose): rotate_tile = 90
	if(flip_x && flip_y && !transpose): rotate_tile = 180
	if(!flip_x && flip_y && transpose): rotate_tile = 270
	rotate_tile += 90
	if rotate_tile == 360: rotate_tile = 0
	
	if rotate_tile == 0:
		flip_x = false
		flip_y = false
		transpose = false
	if rotate_tile == 90:
		flip_x = true
		flip_y = false
		transpose = true
	if rotate_tile == 180:
		flip_x = true
		flip_y = true
		transpose = false
	if rotate_tile == 270:
		flip_x = false
		flip_y = true
		transpose = true
		
	set_cellv(last_pos, tile_to_place, flip_x, flip_y, transpose)

func _on_emitter_player_is_moving(is_moving):
	player_is_moving = is_moving

func _on_emitter_tile_in_hand(tile, lFlip_x, lFlip_y, lTranspose):
	tile_to_place = tile
	self.flip_x = lFlip_x
	self.flip_y = lFlip_y
	self.transpose = lTranspose

func _on_emitter_place_tile():
	emit_signal("move_tile", tile_to_place, last_pos, flip_x, flip_y, transpose)
	flip_x = false
	flip_y = false
	transpose = false
	rotate_tile = 0

func _on_emitter_hovered_tile(tile_pos, hovered_tile):
	if last_pos != null:
			set_cellv(last_pos, -1)
	
	if hovered_tile == 5 || \
	   hovered_tile == 6 || \
	   hovered_tile == 7 || \
	   hovered_tile == 8:
		click_allowed = true
		current_tile = hovered_tile
		set_cellv(tile_pos, tile_to_place, flip_x, flip_y, transpose)
	else:
		click_allowed = false
		
	last_pos = tile_pos
