extends Node2D

const FLAG_SIZE = 32.0


func setup(goal_cell: Vector2i, maze):

	position = maze.cell_to_world(goal_cell)

	queue_redraw()


func _draw():

	# Flag pole
	draw_line(
		Vector2(0, 18),
		Vector2(0, -18),
		Color.WHITE,
		3.0
	)

	# Flag
	var points = PackedVector2Array([
		Vector2(0, -18),
		Vector2(20, -10),
		Vector2(0, -2)
	])

	draw_colored_polygon(
		points,
		Color("#4CAF50")
	)
