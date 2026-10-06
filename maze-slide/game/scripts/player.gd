extends CharacterBody2D

signal moved(direction)

const PLAYER_SIZE = 44.0
const SPEED = 300.0

var grid_position = Vector2i.ZERO
var target_position = Vector2.ZERO

var moving = false
var input_enabled = true
var maze


func setup(start_cell: Vector2i, maze_node):
	grid_position = start_cell
	maze = maze_node

	position = maze.cell_to_world(grid_position)
	target_position = position

	moving = false
	input_enabled = true

	if has_node("Node2D/AnimationPlayer"):
		$Node2D/AnimationPlayer.stop()


func set_input_enabled(enabled: bool):
	input_enabled = enabled


func _input(event):
	if moving or not input_enabled:
		return

	var direction = Vector2i.ZERO

	if event.is_action_pressed("ui_up"):
		direction = Vector2i(0, -1)
		if has_node("Node2D/AnimationPlayer"):
			$Node2D/AnimationPlayer.play("player_walking_up")
		

	elif event.is_action_pressed("ui_down"):
		direction = Vector2i(0, 1)
		if has_node("Node2D/AnimationPlayer"):
			$Node2D/AnimationPlayer.play("player_walking_down")

	elif event.is_action_pressed("ui_left"):
		direction = Vector2i(-1, 0)
		if has_node("Node2D/AnimationPlayer"):
			$Node2D/AnimationPlayer.play("player_walking_left")

	elif event.is_action_pressed("ui_right"):
		direction = Vector2i(1, 0)
		if has_node("Node2D/AnimationPlayer"):
			$Node2D/AnimationPlayer.play("player_walking_right")

	else:
		return
	slide(direction)
	moved.emit(direction)


func slide(direction: Vector2i):
	var current = grid_position

	while true:
		var next = current + direction

		if next.x < 0 or next.x >= maze.grid_size:
			break

		if next.y < 0 or next.y >= maze.grid_size:
			break

		if maze.has_wall_between(current, next):
			break

		current = next

	if current == grid_position:
		return

	grid_position = current

	target_position = maze.cell_to_world(
		grid_position
	)
	moving = true

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

		if has_node("Node2D/AnimationPlayer"):
			$Node2D/AnimationPlayer.stop()


func stop_movement():
	moving = false
	target_position = position

	if has_node("Node2D/AnimationPlayer"):
		$Node2D/AnimationPlayer.stop()
