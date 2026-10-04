extends Node2D

const WALL_THICKNESS = 11.0
const WALL_COLLISION_THICKNESS = 2.0

const FLOOR_TEXTURE = preload(
	"res://assets/Sprites/floor_sterile.png"
)

const HAZARD_HORIZONTAL = preload(
	"res://assets/Sprites/hazard_stripe_H.png"
)

const HAZARD_VERTICAL = preload(
	"res://assets/Sprites/hazard_stripe_V.png"
)

const FLOOR_TILES_X = 3
const FLOOR_TILES_Y = 3

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
			WALL_COLLISION_THICKNESS
		)

	else:

		shape.size = Vector2(
			WALL_COLLISION_THICKNESS,
			length
		)

	collision.shape = shape

	body.position = center
	body.add_child(collision)
	add_child(body)


func _draw():

	# ---------------------------------------------------------
	# FLOOR
	# ---------------------------------------------------------
	# floor_sterile.png contains a 3x3 tileset.
	# Each maze cell receives one tile.
	# The 3x3 pattern repeats across the entire maze.
	# ---------------------------------------------------------

	var texture_size = FLOOR_TEXTURE.get_size()

	var source_tile_size = Vector2(
		texture_size.x / FLOOR_TILES_X,
		texture_size.y / FLOOR_TILES_Y
	)

	for row in range(grid_size):
		for column in range(grid_size):

			# Pick one of the 9 tiles from the 3x3 tileset.
			var tile_x = column % FLOOR_TILES_X
			var tile_y = row % FLOOR_TILES_Y

			var source_rect = Rect2(
				tile_x * source_tile_size.x,
				tile_y * source_tile_size.y,
				source_tile_size.x,
				source_tile_size.y
			)

			var destination_rect = Rect2(
				column * cell_size,
				row * cell_size,
				cell_size,
				cell_size
			)

			#draw_texture_rect_region(
				#FLOOR_TEXTURE,
				#destination_rect,
				#source_rect
			#)


	# ---------------------------------------------------------
	# HORIZONTAL HAZARD STRIPES
	# ---------------------------------------------------------

	for row in range(grid_size + 1):
		for column in range(grid_size):

			if horizontal_walls[row][column] == 1:

				var rect = Rect2(
					column * cell_size,
					row * cell_size - WALL_THICKNESS / 2.0,
					cell_size,
					WALL_THICKNESS
				)

				draw_texture_rect(
					HAZARD_HORIZONTAL,
					rect,
					false
				)


	# ---------------------------------------------------------
	# VERTICAL HAZARD STRIPES
	# ---------------------------------------------------------

	for row in range(grid_size):
		for column in range(grid_size + 1):

			if vertical_walls[row][column] == 1:

				var rect = Rect2(
					column * cell_size - WALL_THICKNESS / 2.0,
					row * cell_size,
					WALL_THICKNESS,
					cell_size
				)

				draw_texture_rect(
					HAZARD_VERTICAL,
					rect,
					false
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

	# ---------------------------------------------------------
	# MOVING HORIZONTALLY
	# ---------------------------------------------------------

	if cell_a.y == cell_b.y:

		var row = cell_a.y

		if cell_b.x > cell_a.x:

			return vertical_walls[row][cell_a.x + 1] == 1

		else:

			return vertical_walls[row][cell_a.x] == 1


	# ---------------------------------------------------------
	# MOVING VERTICALLY
	# ---------------------------------------------------------

	if cell_a.x == cell_b.x:

		var column = cell_a.x

		if cell_b.y > cell_a.y:

			return horizontal_walls[cell_a.y + 1][column] == 1

		else:

			return horizontal_walls[cell_a.y][column] == 1


	return true
