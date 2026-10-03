extends Node2D

const WALL_THICKNESS = 8.0

var grid_size: int
var cell_size: float

var horizontal_walls = []
var vertical_walls = []


func setup(level):

	grid_size = level.GRID_SIZE
	cell_size = level.CELL_SIZE

	horizontal_walls = level.HORIZONTAL_WALLS
	vertical_walls = level.VERTICAL_WALLS

	create_walls()
	queue_redraw()


func create_walls():
	# Horizontal walls
	for row in range(grid_size + 1):
		for column in range(grid_size):

			if horizontal_walls[row][column] == 1:

				var start = Vector2(
					column * cell_size,
					row * cell_size
				)

				var end = Vector2(
					(column + 1) * cell_size,
					row * cell_size
				)

				create_wall(start, end)


	# Vertical walls
	for row in range(grid_size):
		for column in range(grid_size + 1):

			if vertical_walls[row][column] == 1:

				var start = Vector2(
					column * cell_size,
					row * cell_size
				)

				var end = Vector2(
					column * cell_size,
					(row + 1) * cell_size
				)

				create_wall(start, end)


func create_wall(start: Vector2, end: Vector2):

	var body = StaticBody2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()

	var center = (start + end) / 2.0
	var length = start.distance_to(end)

	if start.y == end.y:
		shape.size = Vector2(
			length,
			WALL_THICKNESS
		)
	else:
		shape.size = Vector2(
			WALL_THICKNESS,
			length
		)

	collision.shape = shape

	body.position = center
	body.add_child(collision)
	add_child(body)


func _draw():

	# Background
	draw_rect(
		Rect2(
			0,
			0,
			grid_size * cell_size,
			grid_size * cell_size
		),
		Color("#3d3d3d")
	)


	# Horizontal walls
	for row in range(grid_size + 1):
		for column in range(grid_size):

			if horizontal_walls[row][column] == 1:

				draw_line(
					Vector2(
						column * cell_size,
						row * cell_size
					),
					Vector2(
						(column + 1) * cell_size,
						row * cell_size
					),
					Color.WHITE,
					WALL_THICKNESS
				)


	# Vertical walls
	for row in range(grid_size):
		for column in range(grid_size + 1):

			if vertical_walls[row][column] == 1:

				draw_line(
					Vector2(
						column * cell_size,
						row * cell_size
					),
					Vector2(
						column * cell_size,
						(row + 1) * cell_size
					),
					Color.WHITE,
					WALL_THICKNESS
				)


func cell_to_world(cell: Vector2i) -> Vector2:

	return Vector2(
		cell.x * cell_size + cell_size / 2.0,
		cell.y * cell_size + cell_size / 2.0
	)


func has_wall_between(
	cell_a: Vector2i,
	cell_b: Vector2i
) -> bool:

	# Moving horizontally
	if cell_a.y == cell_b.y:

		var row = cell_a.y

		if cell_b.x > cell_a.x:

			return vertical_walls[row][cell_a.x + 1] == 1

		else:

			return vertical_walls[row][cell_a.x] == 1


	# Moving vertically
	if cell_a.x == cell_b.x:

		var column = cell_a.x

		if cell_b.y > cell_a.y:

			return horizontal_walls[cell_a.y + 1][column] == 1

		else:

			return horizontal_walls[cell_a.y][column] == 1


	return true
