extends Node2D


# ============================================================
# SETTINGS
# ============================================================

const GRID_SIZE = 5
const CELL_SIZE = 60
const WALL_THICKNESS = 2.0


# ============================================================
# MAP DESIGN
# ============================================================
#
# 1 = WALL
# 0 = EMPTY
#
# You ONLY need to edit these two matrices.
#
# ------------------------------------------------------------
# HORIZONTAL WALLS
# ------------------------------------------------------------
#
# 11 rows × 10 columns
#
# Row 0 = TOP BORDER
# Row 1 = between grid row 0 and 1
# Row 2 = between grid row 1 and 2
# ...
# Row 9 = between grid row 8 and 9
# Row 10 = BOTTOM BORDER
#
# ============================================================
#
#var horizontal_walls = [
#
	##  0  1  2  3  4  5  6  7  8  9
	#[ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ], # 0 TOP
	#[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], # 1
	#[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], # 2
	#[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], # 3
	#[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], # 4
	#[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], # 5
	#[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], # 6
	#[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], # 7
	#[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], # 8
	#[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], # 9
	#[ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ], # 10 BOTTOM
#
#]

var horizontal_walls = [

	[1, 1, 1, 1, 1],
	[0, 0, 0, 0, 0],
	[1, 0, 0, 0, 0],
	[1, 0, 0, 0, 1],
	[0, 0, 1, 0, 0],
	[1, 1, 1, 1, 1]

]
# ============================================================
# VERTICAL WALLS
# ============================================================
#
# 10 rows × 11 columns
#
# Column 0  = LEFT BORDER
# Column 1  = between cell 0 and 1
# Column 2  = between cell 1 and 2
# ...
# Column 9  = between cell 8 and 9
# Column 10 = RIGHT BORDER
#
# ============================================================
#
#var vertical_walls = [
#
	##  0  1  2  3  4  5  6  7  8  9  10
	#[ 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1 ], # row 0
	#[ 1, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1 ], # row 1
	#[ 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1 ], # row 2
	#[ 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1 ], # row 3
	#[ 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1 ], # row 4
	#[ 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1 ], # row 5
	#[ 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 1 ], # row 6
	#[ 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1 ], # row 7
	#[ 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1 ], # row 8
	#[ 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1 ], # row 9
#
#]

var vertical_walls = [

	[1, 0, 1, 0, 0, 1],
	[1, 0, 0, 1, 0, 1],
	[1, 0, 0, 0, 0, 1],
	[1, 0, 0, 1, 0, 1],
	[1, 0, 0, 0, 0, 1]

]

# ============================================================
# START
# ============================================================

func _ready():

	create_walls()

	queue_redraw()


# ============================================================
# CREATE WALLS
# ============================================================

func create_walls():

	# --------------------------------------------
	# HORIZONTAL
	# --------------------------------------------

	for row in range(GRID_SIZE + 1):

		for column in range(GRID_SIZE):

			if horizontal_walls[row][column] == 1:

				var start = Vector2(
					column * CELL_SIZE,
					row * CELL_SIZE
				)

				var end = Vector2(
					(column + 1) * CELL_SIZE,
					row * CELL_SIZE
				)

				create_wall(start, end)


	# --------------------------------------------
	# VERTICAL
	# --------------------------------------------

	for row in range(GRID_SIZE):

		for column in range(GRID_SIZE + 1):

			if vertical_walls[row][column] == 1:

				var start = Vector2(
					column * CELL_SIZE,
					row * CELL_SIZE
				)

				var end = Vector2(
					column * CELL_SIZE,
					(row + 1) * CELL_SIZE
				)

				create_wall(start, end)


# ============================================================
# DRAW
# ============================================================

func _draw():

	# Background

	draw_rect(
		Rect2(
			0,
			0,
			GRID_SIZE * CELL_SIZE,
			GRID_SIZE * CELL_SIZE
		),
		Color("#3d3d3d")
	)


	# Horizontal walls

	for row in range(GRID_SIZE + 1):

		for column in range(GRID_SIZE):

			if horizontal_walls[row][column] == 1:

				draw_line(
					Vector2(
						column * CELL_SIZE,
						row * CELL_SIZE
					),
					Vector2(
						(column + 1) * CELL_SIZE,
						row * CELL_SIZE
					),
					Color.WHITE,
					WALL_THICKNESS
				)


	# Vertical walls

	for row in range(GRID_SIZE):

		for column in range(GRID_SIZE + 1):

			if vertical_walls[row][column] == 1:

				draw_line(
					Vector2(
						column * CELL_SIZE,
						row * CELL_SIZE
					),
					Vector2(
						column * CELL_SIZE,
						(row + 1) * CELL_SIZE
					),
					Color.WHITE,
					WALL_THICKNESS
				)


# ============================================================
# CREATE COLLISION
# ============================================================

func create_wall(start: Vector2, end: Vector2):

	var body = StaticBody2D.new()

	var collision = CollisionShape2D.new()

	var shape = RectangleShape2D.new()


	var center = (start + end) / 2

	var length = start.distance_to(end)


	if start.y == end.y:

		# Horizontal wall

		shape.size = Vector2(
			length,
			WALL_THICKNESS
		)

	else:

		# Vertical wall

		shape.size = Vector2(
			WALL_THICKNESS,
			length
		)


	collision.shape = shape

	body.position = center

	body.add_child(collision)

	add_child(body)

func has_wall_between(
	cell_a: Vector2i,
	cell_b: Vector2i
) -> bool:

	# Moving horizontally
	if cell_a.y == cell_b.y:

		var row = cell_a.y

		# Moving RIGHT
		if cell_b.x > cell_a.x:

			return vertical_walls[row][cell_a.x + 1] == 1

		# Moving LEFT
		else:

			return vertical_walls[row][cell_a.x] == 1


	# Moving vertically
	if cell_a.x == cell_b.x:

		var column = cell_a.x

		# Moving DOWN
		if cell_b.y > cell_a.y:

			return horizontal_walls[cell_a.y + 1][column] == 1

		# Moving UP
		else:

			return horizontal_walls[cell_a.y][column] == 1


	return true
