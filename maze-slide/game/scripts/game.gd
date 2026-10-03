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

	for enemy in enemies:
		if enemy.visible:
			enemy.move_in_direction(direction)


func _physics_process(_delta):
	if game_over:
		return

	check_enemy_collisions()

	if game_over:
		return

	check_player_enemy_collisions()

	if game_over:
		return

	check_player_goal()


func check_enemy_collisions():
	for i in range(enemies.size()):
		var enemy_a = enemies[i]

		if not enemy_a.visible:
			continue

		for j in range(i + 1, enemies.size()):
			var enemy_b = enemies[j]

			if not enemy_b.visible:
				continue

			if enemies_touching(enemy_a, enemy_b):
				resolve_enemy_collision(enemy_a, enemy_b)


func enemies_touching(a, b) -> bool:
	return abs(a.global_position.x - b.global_position.x) <= ENEMY_SIZE \
		and abs(a.global_position.y - b.global_position.y) <= ENEMY_SIZE


func resolve_enemy_collision(a, b):
	if a.moving and not b.moving:
		stop_enemy_next_to(a, b)
	elif b.moving and not a.moving:
		stop_enemy_next_to(b, a)
	elif a.moving and b.moving:
		var a_remaining = a.position.distance_to(a.target_position)
		var b_remaining = b.position.distance_to(b.target_position)

		if a_remaining > b_remaining:
			stop_enemy_next_to(a, b)
		else:
			stop_enemy_next_to(b, a)


func stop_enemy_next_to(enemy, other):
	var difference = enemy.global_position - other.global_position
	var direction = Vector2i.ZERO

	if abs(difference.x) > abs(difference.y):
		direction.x = sign(difference.x)
	else:
		direction.y = sign(difference.y)

	enemy.stop_next_to(other, direction)


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
