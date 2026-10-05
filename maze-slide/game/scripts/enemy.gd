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
	target_position = position

	moving = false
	if has_node("EnemyNode1/EnemyAnimationPlayer1"):
		$EnemyNode1/EnemyAnimationPlayer1.stop()

	queue_redraw()


func get_slide_target(
	direction: Vector2i,
	blocked_cells: Array
) -> Vector2i:

	var current = grid_position

	while true:
		var next = current + direction

		if next.x < 0 or next.x >= maze.grid_size:
			break

		if next.y < 0 or next.y >= maze.grid_size:
			break

		if maze.has_wall_between(current, next):
			break

		if next in blocked_cells:
			break

		current = next

	return current


func move_in_direction(
	direction: Vector2i,
	blocked_cells: Array
):
	if moving:
		return

	var destination = get_slide_target(
		direction,
		blocked_cells
	)

	if destination == grid_position:
		return

	grid_position = destination
	target_position = maze.cell_to_world(
		grid_position
	)
	
	moving = true


func _physics_process(delta):
	if not moving:
		return
	if has_node("Maze/Enemy1/EnemyNode1/EnemyAnimationPlayer1"):
		$Maze/Enemy1/EnemyNode1/EnemyAnimationPlayer1.play("enemy_walking")
	position = position.move_toward(
		target_position,
		SPEED * delta
	)

	if position.distance_to(target_position) < 0.1:
		position = target_position
		moving = false
		
		if has_node("EnemyNode1/EnemyAnimationPlayer1"):
			$EnemyNode1/EnemyAnimationPlayer1.stop()


func stop_movement():
	moving = false
	
	if has_node("EnemyNode1/EnemyAnimationPlayer1"):
		$EnemyNode1/EnemyAnimationPlayer1.stop()
		
	target_position = position
