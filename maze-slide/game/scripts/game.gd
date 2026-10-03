extends Node2D

@onready var maze = $Maze
@onready var player = $Maze/Player
@onready var goal = $Maze/Goal

const PLAYER_SIZE = 44.0
const ENEMY_SIZE = 44.0

var LEVEL
var game_over = false
var enemies: Array[Node] = []


func _ready():
	LEVEL = LevelManager.get_current_level()

	maze.setup(LEVEL)
	center_maze()

	player.setup(LEVEL.PLAYER_START, maze)
	goal.setup(LEVEL.GOAL_POSITION, maze)

	find_enemies()
	setup_enemies()

	player.moved.connect(_on_player_moved)
	setup_popup_connections()


func center_maze():
	var viewport_size = get_viewport_rect().size
	var maze_size = Vector2(
		LEVEL.GRID_SIZE * LEVEL.CELL_SIZE,
		LEVEL.GRID_SIZE * LEVEL.CELL_SIZE
	)

	maze.position = (viewport_size - maze_size) / 2.0


func find_enemies():
	enemies.clear()

	for child in maze.get_children():
		if child is CharacterBody2D and child.name.begins_with("Enemy"):
			enemies.append(child)


func setup_enemies():
	if "ENEMY_STARTS" in LEVEL:
		var starts = LEVEL.ENEMY_STARTS

		for i in range(enemies.size()):
			if i < starts.size():
				enemies[i].visible = true
				enemies[i].setup(starts[i], maze)
			else:
				enemies[i].visible = false
				enemies[i].stop_movement()
	else:
		if enemies.size() > 0:
			enemies[0].visible = true
			enemies[0].setup(LEVEL.ENEMY_START, maze)

		for i in range(1, enemies.size()):
			enemies[i].visible = false
			enemies[i].stop_movement()


func _on_player_moved(direction: Vector2i):
	if game_over:
		return
	
	if direction.x != 0:
		move_enemies_horizontal(direction.x)
	else:
		move_enemies_vertical(direction.y)

func move_enemies_horizontal(direction: int):
	var groups = {}

	for enemy in enemies:
		if not enemy.visible:
			continue

		var row = enemy.grid_position.y

		if not groups.has(row):
			groups[row] = []

		groups[row].append(enemy)
	

	for row in groups:
		var group = groups[row]

		# The enemy furthest in the direction of travel is first.
		group.sort_custom(func(a, b):
			if direction > 0:
				return a.grid_position.x > b.grid_position.x
			else:
				return a.grid_position.x < b.grid_position.x
		)

		var front_cells: Array = []
		var ctr = 0
		for enemy in group:
			var destination = enemy.get_slide_target(
				Vector2i(direction, 0),
				front_cells
			)

			front_cells.append(destination)

			enemy.grid_position = destination
			enemy.target_position = maze.cell_to_world(destination)
			enemy.moving = true


func move_enemies_vertical(direction: int):
	
	var groups = {}

	for enemy in enemies:
		if not enemy.visible:
			continue

		var column = enemy.grid_position.x

		if not groups.has(column):
			groups[column] = []

		groups[column].append(enemy)

	for column in groups:
		var group = groups[column]

		group.sort_custom(func(a, b):
			if direction > 0:
				return a.grid_position.y > b.grid_position.y
			else:
				return a.grid_position.y < b.grid_position.y
		)

		var front_cells: Array = []

		for enemy in group:
			var old_position = enemy.grid_position

			var destination = enemy.get_slide_target(
				Vector2i(0, direction),
				front_cells
			)

			front_cells.append(destination)

			if destination != old_position:
				enemy.grid_position = destination
				enemy.target_position = maze.cell_to_world(destination)
				enemy.moving = true


func _physics_process(_delta):
	if game_over:
		return

	check_player_enemy_collisions()

	if game_over:
		return

	check_player_goal()


func check_player_enemy_collisions():
	for enemy in enemies:
		if enemy.visible and player_touches_enemy(enemy):
			die()
			return


func player_touches_enemy(enemy) -> bool:
	return abs(player.global_position.x - enemy.global_position.x) <= PLAYER_SIZE \
		and abs(player.global_position.y - enemy.global_position.y) <= PLAYER_SIZE


func check_player_goal():
	if not player_touches_goal():
		return

	if any_enemy_touches_goal():
		die()
	else:
		win()


func player_touches_goal() -> bool:
	return abs(player.global_position.x - goal.global_position.x) <= 38.0 \
		and abs(player.global_position.y - goal.global_position.y) <= 38.0


func any_enemy_touches_goal() -> bool:
	for enemy in enemies:
		if enemy.visible and enemy_touches_goal(enemy):
			return true

	return false


func enemy_touches_goal(enemy) -> bool:
	return abs(enemy.global_position.x - goal.global_position.x) <= 38.0 \
		and abs(enemy.global_position.y - goal.global_position.y) <= 38.0


func die():
	if game_over:
		return

	game_over = true

	player.stop_movement()

	for enemy in enemies:
		if enemy.visible:
			enemy.stop_movement()

	print("YOU DIED!")

	await get_tree().create_timer(0.5).timeout
	reset_level()


func win():
	if game_over:
		return

	game_over = true

	player.stop_movement()

	for enemy in enemies:
		if enemy.visible:
			enemy.stop_movement()

	print("LEVEL WON!")
	show_level_won_popup()


func reset_level():
	game_over = false

	player.setup(LEVEL.PLAYER_START, maze)
	setup_enemies()
	goal.setup(LEVEL.GOAL_POSITION, maze)

	if has_node("GameUI/Controls/LevelWonPopup"):
		$GameUI/Controls/LevelWonPopup.visible = false


func show_level_won_popup():
	if has_node("GameUI/Controls/LevelWonPopup"):
		$GameUI/Controls/LevelWonPopup.visible = true


func setup_popup_connections():
	if not has_node("GameUI/Controls/LevelWonPopup"):
		return

	var popup = $GameUI/Controls/LevelWonPopup

	if popup.has_node("VBoxContainer/NextLevelButton"):
		var next_button = popup.get_node("VBoxContainer/NextLevelButton")

		if not next_button.pressed.is_connected(_on_next_level_pressed):
			next_button.pressed.connect(_on_next_level_pressed)

	if popup.has_node("VBoxContainer/RetryButton"):
		var retry_button = popup.get_node("VBoxContainer/RetryButton")

		if not retry_button.pressed.is_connected(_on_retry_pressed):
			retry_button.pressed.connect(_on_retry_pressed)


func _on_next_level_pressed():
	if LevelManager.current_level_index + 1 >= LevelManager.get_level_count():
		print("GAME COMPLETE!")
		return

	LevelManager.set_level(LevelManager.current_level_index + 1)
	get_tree().reload_current_scene()


func _on_retry_pressed():
	reset_level()


func _on_reset_button_pressed():
	reset_level()
