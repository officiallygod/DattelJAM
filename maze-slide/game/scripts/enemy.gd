extends CharacterBody2D

@onready var animation_player = $EnemyNode1/EnemyAnimationPlayer1

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
	animation_player.stop()
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
	position = position.move_toward(
		target_position,
		SPEED * delta
	)

	if position.distance_to(target_position) < 0.1:
		position = target_position
		moving = false
		animation_player.stop()

func stop_movement():
	moving = false
	animation_player.stop()
	target_position = position
	
func play_walking_animation(direction: int, walking_horizontally: bool):
	if (walking_horizontally and direction > 0):
		animation_player.play("enemy_walking_right")
	elif(walking_horizontally and direction < 0):
		animation_player.play("enemy_walking_left")
	elif (!walking_horizontally and direction < 0):
		animation_player.play("enemy_walking_up")
	elif(!walking_horizontally and direction > 0):
		animation_player.play("enemy_walking_down")
