extends Node2D

var sleep_bar = 10
var score = 0

signal game_end()

# Called when the node enters the scene tree for the first time.
func _ready():
	var _connect = get_node("../../Character").connect("player_is_moving", self, "_on_emitter_player_is_moving")
	_connect = get_node("../../Hover").connect("place_tile", self, "_on_emitter_place_tile")

func _display_health():
	var children = get_children()[sleep_bar - 1]
	children.hide()

func _on_emitter_place_tile():
	_display_health()
	sleep_bar -= 1
	score += 10
	if sleep_bar <= 0:
		emit_signal("game_end")

func _on_emitter_player_is_moving(is_moving):
	if is_moving:
		_display_health()
		sleep_bar -= 1
		score += 10
	if !is_moving && sleep_bar <= 0:
		emit_signal("game_end")
