extends Node2D

@onready var maze = $Maze
@onready var player = $Maze/Player
@onready var goal = $Maze/Goal
@onready var game_win = $Sounds/GameWin
@onready var player_win = $Sounds/PlayerWin
@onready var player_lose = $Sounds/PlayerLose

const PLAYER_SIZE = 44.0
const ENEMY_SIZE = 44.0
const LevelGen = preload("res://game/scripts/level_generator.gd")
const background_music = preload("res://assets/audios/mixkit-infinity-440.mp3")


var LEVEL
var random_level: Node
var game_over = false
var turn_in_progress = false
var enemies: Array[Node] = []


func _ready():
	MusicPlayer.play_music(background_music, -25.0)
	LEVEL = LevelManager.get_current_level()
	if LevelManager.get_random_level():
		LEVEL = LevelGenerator.generate()
		
	maze.setup(LEVEL)
	center_maze()
	
	#if has_node("Maze/Goal/GoalNode/GoalAnimationPlayer"):
		#$Maze/Goal/GoalNode/GoalAnimationPlayer.play("portal")

	player.setup(LEVEL.PLAYER_START, maze)
	goal.setup(LEVEL.GOAL_POSITION, maze)

	find_enemies()
	setup_enemies()

	player.moved.connect(_on_player_moved)
	setup_popup_connections()
	setup_popup_connections2()
	


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
	if game_over or turn_in_progress:
		return

	turn_in_progress = true
	player.set_input_enabled(false)

	move_enemies(direction)

	await wait_for_all_movement()

	if game_over:
		return

	check_player_enemy_collisions()

	if game_over:
		return

	check_player_goal()

	if not game_over:
		turn_in_progress = false
		player.set_input_enabled(true)


func move_enemies(direction: Vector2i):
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

		group.sort_custom(func(a, b):
			if direction > 0:
				return a.grid_position.x > b.grid_position.x
			else:
				return a.grid_position.x < b.grid_position.x
		)

		var front_cells: Array = []

		for enemy in group:
			var old_position = enemy.grid_position

			var destination = enemy.get_slide_target(
				Vector2i(direction, 0),
				front_cells
			)

			front_cells.append(destination)

			if destination != old_position:
				enemy.move_in_direction(Vector2i(direction, 0), front_cells)
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
				enemy.move_in_direction(Vector2i(0, direction), front_cells)
				enemy.grid_position = destination
				enemy.target_position = maze.cell_to_world(destination)
				enemy.moving = true


func wait_for_all_movement():
	while player.moving or any_enemy_moving():
		await get_tree().process_frame


func any_enemy_moving() -> bool:
	for enemy in enemies:
		if enemy.visible and enemy.moving:
			return true

	return false


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
	return abs(
		player.global_position.x - enemy.global_position.x
	) <= PLAYER_SIZE and abs(
		player.global_position.y - enemy.global_position.y
	) <= PLAYER_SIZE


func check_player_goal():
	if not player_touches_goal():
		return

	if any_enemy_touches_goal():
		die()
	else:
		win()


func player_touches_goal() -> bool:
	var player_rect = Rect2(
		player.global_position - Vector2(
			PLAYER_SIZE / 2.0,
			PLAYER_SIZE / 2.0
		),
		Vector2(
			PLAYER_SIZE,
			PLAYER_SIZE
		)
	)

	var goal_rect = Rect2(
		goal.global_position - Vector2(10, 20),
		Vector2(30, 40)
	)

	return player_rect.intersects(goal_rect)


func any_enemy_touches_goal() -> bool:
	for enemy in enemies:
		if enemy.visible and enemy_touches_goal(enemy):
			return true

	return false


func enemy_touches_goal(enemy) -> bool:
	var enemy_rect = Rect2(
		enemy.global_position - Vector2(
			ENEMY_SIZE / 2.0,
			ENEMY_SIZE / 2.0
		),
		Vector2(
			ENEMY_SIZE,
			ENEMY_SIZE
		)
	)

	var goal_rect = Rect2(
		goal.global_position - Vector2(10, 20),
		Vector2(30, 40)
	)

	return enemy_rect.intersects(goal_rect)


func die():
	if game_over:
		return

	game_over = true
	turn_in_progress = true

	player_lose.play()
	player.stop_movement()
	player.set_input_enabled(false)

	for enemy in enemies:
		if enemy.visible:
			enemy.stop_movement()
			
	if has_node("Maze/Enemy1/EnemyNode/EnemyAnimationPlayer"):
		$Maze/Enemy1/EnemyNode/EnemyAnimationPlayer.stop()
	if has_node("Maze/Enemy2/EnemyNode/EnemyAnimationPlayer"):
		$Maze/Enemy2/EnemyNode/EnemyAnimationPlayer.stop()
	if has_node("Maze/Enemy3/EnemyNode/EnemyAnimationPlayer"):
		$Maze/Enemy3/EnemyNode/EnemyAnimationPlayer.stop()
	print("YOU DIED!")

	await get_tree().create_timer(0.8).timeout

	reset_level()


func win():
	if game_over:
		return

	game_over = true
	turn_in_progress = true

	player.stop_movement()
	player.set_input_enabled(false)

	for enemy in enemies:
		if enemy.visible:
			enemy.stop_movement()

	player.position = goal.position
	player.target_position = goal.position

	print("LEVEL WON!")
	await get_tree().create_timer(0.8).timeout

	if LevelManager.current_level_index + 1 >= LevelManager.get_level_count():
		show_game_won_popup()
		game_win.play()
		return
	show_level_won_popup()
	player_win.play()
	


func reset_level():
	game_over = false
	turn_in_progress = false

	player.setup(
		LEVEL.PLAYER_START,
		maze
	)

	setup_enemies()

	goal.setup(
		LEVEL.GOAL_POSITION,
		maze
	)

	if has_node("GameUI/Controls/WinBackground"):
		$GameUI/Controls/WinBackground.visible = false

	if has_node("GameUI/Controls/LevelWonPopup"):
		$GameUI/Controls/LevelWonPopup.visible = false

	if has_node("GameUI/Controls/GameWonPopup"):
		$GameUI/Controls/GameWonPopup.visible = false


func show_level_won_popup():
	if has_node("GameUI/Controls/WinBackground"):
		$GameUI/Controls/WinBackground.visible = true

	if has_node("GameUI/Controls/LevelWonPopup"):
		$GameUI/Controls/LevelWonPopup.visible = true


func setup_popup_connections():
	if not has_node("GameUI/Controls/LevelWonPopup"):
		return

	var popup = $GameUI/Controls/LevelWonPopup

	if popup.has_node("VBoxContainer/NextLevelButton"):
		var next_button = popup.get_node(
			"VBoxContainer/NextLevelButton"
		)

		if not next_button.pressed.is_connected(
			_on_next_level_pressed
		):
			next_button.pressed.connect(
				_on_next_level_pressed
			)

	if popup.has_node("VBoxContainer/RetryButton"):
		var retry_button = popup.get_node(
			"VBoxContainer/RetryButton"
		)

		if not retry_button.pressed.is_connected(
			_on_retry_pressed
		):
			retry_button.pressed.connect(
				_on_retry_pressed
			)


func _on_next_level_pressed():
	if not LevelManager.get_random_level():
		if LevelManager.current_level_index + 1 >= LevelManager.get_level_count():
			print("GAME COMPLETE!")
			return

		LevelManager.set_level(
			LevelManager.current_level_index + 1
		)

	get_tree().reload_current_scene()

func show_game_won_popup():
	if has_node("GameUI/Controls/WinBackground"):
		$GameUI/Controls/WinBackground.visible = true

	if has_node("GameUI/Controls/GameWonPopup"):
		$GameUI/Controls/GameWonPopup.visible = true

func setup_popup_connections2():
	if not has_node("GameUI/Controls/GameWonPopup"):
		return

	var popup = $GameUI/Controls/GameWonPopup


	if popup.has_node("VBoxContainer/RetryButton"):
		var retry_button = popup.get_node(
			"VBoxContainer/RetryButton"
		)

		if not retry_button.pressed.is_connected(
			_on_retry_pressed
		):
			retry_button.pressed.connect(
				_on_retry_pressed
			)

func _on_retry_pressed():
	reset_level()


func _on_reset_button_pressed():
	reset_level()
