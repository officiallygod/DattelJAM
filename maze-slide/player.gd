extends CharacterBody2D

const CELL_SIZE = 60.0
const PLAYER_SIZE = 44.0
const SPEED = 300.0

var grid_position = Vector2i(0, 0)

var moving = false
var target_position = Vector2.ZERO


func _ready():

	# Start in cell (0, 0)
	grid_position = Vector2i(0, 3)

	position = cell_to_world(grid_position)

	# Draw player
	queue_redraw()


func _physics_process(delta):

	if not moving:
		return

	position = position.move_toward(
		target_position,
		SPEED * delta
	)

	if position.distance_to(target_position) < 0.1:

		# EXACTLY center the player
		position = target_position

		moving = false


func _input(event):

	if moving:
		return

	if event.is_action_pressed("ui_up"):
		slide(Vector2i(0, -1))

	elif event.is_action_pressed("ui_down"):
		slide(Vector2i(0, 1))

	elif event.is_action_pressed("ui_left"):
		slide(Vector2i(-1, 0))

	elif event.is_action_pressed("ui_right"):
		slide(Vector2i(1, 0))


func slide(direction: Vector2i):

	var maze = get_node("../Maze")

	var current = grid_position

	# Keep moving through cells until we hit a wall
	while true:

		var next = current + direction

		# Don't leave the 10x10 grid
		if next.x < 0 or next.x >= 5:
			break

		if next.y < 0 or next.y >= 5:
			break

		# Is there a wall between the cells?
		if maze.has_wall_between(current, next):
			break

		current = next

	# We didn't move
	if current == grid_position:
		return

	# Update grid position
	grid_position = current

	# Move to exact center of destination cell
	target_position = cell_to_world(grid_position)

	moving = true


func cell_to_world(cell: Vector2i) -> Vector2:

	return Vector2(
		cell.x * CELL_SIZE + CELL_SIZE / 2.0,
		cell.y * CELL_SIZE + CELL_SIZE / 2.0
	)


# ============================================================
# DRAW PLAYER
# ============================================================

func _draw():

	draw_rect(
		Rect2(
			-PLAYER_SIZE / 2.0,
			-PLAYER_SIZE / 2.0,
			PLAYER_SIZE,
			PLAYER_SIZE
		),
		Color.WHITE
	)
