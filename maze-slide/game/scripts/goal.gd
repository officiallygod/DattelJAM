extends Node2D

const FLAG_SIZE = 32.0

func setup(goal_cell: Vector2i, maze):

	position = maze.cell_to_world(goal_cell)

	queue_redraw()
