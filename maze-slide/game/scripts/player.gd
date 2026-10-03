extends CharacterBody2D

signal moved(direction)

const PLAYER_SIZE = 44.0
const SPEED = 300.0

var grid_position = Vector2i.ZERO
var target_position = Vector2.ZERO
var moving = false
var maze


func setup(start_cell: Vector2i, maze_node):
	grid_position = start_cell
	maze = maze_node

	position = maze.cell_to_world(grid_position)
	target_position = position

	moving = false

	queue_redraw()


func _input(event):

	if moving:
		return

	var direction = Vector2i.ZERO

	if event.is_action_pressed("ui_up"):
		direction = Vector2i(0, -1)

	elif event.is_action_pressed("ui_down"):
		direction = Vector2i(0, 1)

	elif event.is_action_pressed("ui_left"):
		direction = Vector2i(-1, 0)

	elif event.is_action_pressed("ui_right"):
		direction = Vector2i(1, 0)

	else:
		return

	slide(direction)
	moved.emit(direction)


func slide(direction: Vector2i):

	var current = grid_position

	while true:

		var next = current + direction

		# Outside the level
		if next.x < 0 or next.x >= maze.grid_size:
			break

		if next.y < 0 or next.y >= maze.grid_size:
			break

		# Wall
		if maze.has_wall_between(current, next):
			break

		current = next

	# Didn't move
	if current == grid_position:
		return

	grid_position = current

	target_position = maze.cell_to_world(grid_position)

	moving = true
	
	$Node2D/AnimationPlayer.play("walk")


func _physics_process(delta):

	if not moving:
		return

	position = position.move_toward(
		target_position,
		SPEED * delta
	)

	if position.distance_to(target_position) < 0.1:

		position = target_position
		moving = false
		$Node2D/AnimationPlayer.stop()


func stop_movement():
	moving = false
	target_position = position
	$Node2D/AnimationPlayer.stop()


#func _draw():
#
	#draw_rect(
		#Rect2(
			#-PLAYER_SIZE / 2.0,
			#-PLAYER_SIZE / 2.0,
			#PLAYER_SIZE,
			#PLAYER_SIZE
		#),
		#Color.WHITE
	#)
