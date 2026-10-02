extends Node2D


# ==========================================
# CURRENT LEVEL
# ==========================================

const LEVEL = preload("res://levels/level_02.gd")


# ==========================================
# NODES
# ==========================================

@onready var maze = $Maze
@onready var player = $Player
@onready var enemy = $Enemy
@onready var goal = $Goal


var game_over = false


# ==========================================
# START GAME
# ==========================================

func _ready():

	maze.setup(LEVEL)

	player.setup(
		LEVEL.PLAYER_START,
		maze
	)

	enemy.setup(
		LEVEL.ENEMY_START,
		maze
	)

	goal.setup(
		LEVEL.GOAL_POSITION,
		maze
	)

	player.moved.connect(
		_on_player_moved
	)


# ==========================================
# PLAYER MOVED
# ==========================================

func _on_player_moved(direction: Vector2i):

	if game_over:
		return


	# Enemy copies player's direction
	enemy.move_in_direction(direction)


	# Wait for both to finish sliding
	await wait_for_movement()


	# ========================================
	# PLAYER REACHED GOAL
	# ========================================

	if player.grid_position == LEVEL.GOAL_POSITION:

		win()
		return


	# ========================================
	# ENEMY COLLIDED WITH PLAYER
	# ========================================

	if player.grid_position == enemy.grid_position:

		die()


# ==========================================
# WAIT FOR MOVEMENT
# ==========================================

func wait_for_movement():

	while player.moving or enemy.moving:

		await get_tree().process_frame


# ==========================================
# DEATH
# ==========================================

func die():

	if game_over:
		return

	game_over = true

	print("YOU DIED!")


	await get_tree().create_timer(0.5).timeout


	reset_level()


# ==========================================
# RESET
# ==========================================

func reset_level():

	player.setup(
		LEVEL.PLAYER_START,
		maze
	)

	enemy.setup(
		LEVEL.ENEMY_START,
		maze
	)

	game_over = false


# ==========================================
# WIN
# ==========================================

func win():

	if game_over:
		return

	game_over = true

	print("YOU WIN!")
