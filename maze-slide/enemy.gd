extends CharacterBody2D

const ENEMY_SIZE = 44.0
const SPEED = 300.0

var grid_position = Vector2i.ZERO
var target_position = Vector2.ZERO

var moving = false
var maze


func setup(start_cell: Vector2i, maze_node):

	grid_position = start_cell
	maze = maze_node

	position = maze.cell_to_world(grid_position)

	moving = false

	queue_redraw()


func move_in_direction(direction: Vector2i):

	if moving:
		return


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


func _draw():

	draw_rect(
		Rect2(
			-ENEMY_SIZE / 2.0,
			-ENEMY_SIZE / 2.0,
			ENEMY_SIZE,
			ENEMY_SIZE
		),
		Color.RED
	)
