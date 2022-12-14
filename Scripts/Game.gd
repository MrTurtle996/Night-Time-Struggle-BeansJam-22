extends Node2D

var _player_position
var _goal_position
var score = 0

func _ready():
	var _connect = get_node("UI/SleepBar").connect("game_end", self, "_on_emitter_game_end")
	_connect = get_node("Character").connect("player_position", self, "_on_emitter_player_position")

func _process(_delta):
	get_node("UI/Score").text = str(Score.score)

func _on_emitter_game_end():
	if get_node("Character").position == get_node("Goal").position:
		Score.won = true
		var _value = get_tree().change_scene("res://Scenes/GameOver.tscn")
	else:
		Score.won = false
		var _value = get_tree().change_scene("res://Scenes/GameOver.tscn")

func _on_emitter_goal_position(pos):
	_goal_position = pos

func _on_emitter_player_position(pos):
	_player_position = pos
