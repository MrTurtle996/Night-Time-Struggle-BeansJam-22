extends KinematicBody2D


export var speed : int
export var tile_size : int

var new_position
var current_position
var is_moving = false
var velocity = Vector2()

signal player_position(pos)
signal player_is_moving(moving)

func _ready():
	new_position = position
	emit_signal("player_position", new_position)

func get_input():
	velocity = Vector2()
	if Input.is_action_just_pressed("ui_up"):
		velocity.y -= 1
		new_position = Vector2(position.x, position.y - tile_size)
	if Input.is_action_just_pressed("ui_right"):
		velocity.x += 1
		new_position = Vector2(position.x + tile_size, position.y)
	if Input.is_action_just_pressed("ui_down"):
		velocity.y += 1
		new_position = Vector2(position.x, position.y + tile_size)
	if Input.is_action_just_pressed("ui_left"):
		velocity.x -= 1
		new_position = Vector2(position.x - tile_size, position.y)
	velocity = velocity.normalized() * speed

func _physics_process(delta):
	current_position = position
	if !is_moving:
		get_input()
		var collision = move_and_collide(velocity)
		
		if velocity != Vector2():
			if collision:
				var meta = collision.collider.name
				
				if(meta == "Map"):
					position = current_position
			else:
				position = current_position
				is_moving = true
				emit_signal("player_is_moving", is_moving)
	if is_moving:
		position = position.move_toward(new_position, delta * speed)
		emit_signal("player_position", new_position)
	if new_position == position:
		is_moving = false
		emit_signal("player_is_moving", is_moving)
