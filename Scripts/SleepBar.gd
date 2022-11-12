extends Node2D

var sleep_bar = 20
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
	Score.score += 20
	if sleep_bar <= 0:
		emit_signal("game_end")

func _on_emitter_player_is_moving(is_moving):
	if is_moving:
		_display_health()
		sleep_bar -= 1
		Score.score += 10
	if !is_moving && sleep_bar <= 0:
		emit_signal("game_end")

func _process(_delta):
	if Score.collected_coffee:
		Score.collected_coffee = false
		get_node("../../DrinkMusic").play()
		sleep_bar = 20
		Score.score += 50
		for child in get_children():
			child.visible = true
	
	if Score.collected_sheep:
		Score.collected_sheep = false
		get_node("../../SheepMusic").play()
		for i in 4:
			_display_health()
			sleep_bar -= 1
		if(sleep_bar <= 0):
			emit_signal("game_end")
		Score.score += 150
