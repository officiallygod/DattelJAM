class_name LevelGenerator
extends RefCounted
const LevelData = preload("res://levels/leveldata.gd")
const DIRECTIONS: Dictionary = {
	"UP": Vector2i.UP, "DOWN": Vector2i.DOWN, "LEFT": Vector2i.LEFT, "RIGHT": Vector2i.RIGHT
}
class PuzzleState:
	var player: Vector2i
	var enemy: Vector2i
	
	func _init(player_position: Vector2i, enemy_position: Vector2i) -> void:
		player = player_position
		enemy = enemy_position
	
	func to_key() -> String:
		return "%d,%d;%d,%d" % [player.x, player.y, enemy.x, enemy.y]
	
static func create_matrix(n:int, m:int) -> Array:
	var matrix: Array = []
	var number_rows = n
	var number_columns = m
	var first_row: Array = []
	first_row.resize(m)
	first_row.fill(1)
	if n > m:
		matrix.append(first_row)
		number_rows = number_rows - 2
	for y in range(number_rows) :
		var row: Array = []
		row.resize(m)
		row.fill(0)
		if n < m:
			row[0] = 1
			row[row.size() - 1] = 1
		matrix.append(row);
	if n > m:
		matrix.append(first_row)
	return matrix
	
static func slide(position: Vector2i, direction: Vector2i, horizontal_walls: Array, vertical_walls: Array) -> Vector2i:
	var current_position = position
	var max_steps = horizontal_walls.size() + 2
	while max_steps > 0:
		max_steps -= 1
		if direction == Vector2i.UP:
			if current_position.y <= 0:
				break
			if(horizontal_walls[current_position.y][current_position.x] == 1):
				break
			current_position.y -= 1
		elif direction == Vector2i.DOWN:
			if current_position.y >= vertical_walls.size() - 1:
				break
			if(horizontal_walls[current_position.y + 1][current_position.x] == 1):
				break
			current_position.y += 1
		elif direction == Vector2i.LEFT:
			if current_position.x <= 0:
				break
			if(vertical_walls[current_position.y][current_position.x] == 1):
				break
			current_position.x -= 1
		elif direction == Vector2i.RIGHT:
			if current_position.x >= horizontal_walls[0].size() - 1:
				break
			if(vertical_walls[current_position.y][current_position.x + 1] == 1):
				break
			current_position.x += 1
	return current_position
					
static func step(state: PuzzleState, direction: Vector2i, horizontal_walls: Array, vertical_walls: Array) -> PuzzleState:
	var new_player = slide(state.player, direction, horizontal_walls, vertical_walls)
	var new_enemy = slide(state.enemy, direction, horizontal_walls, vertical_walls)
	if new_player == new_enemy:
		return null
	if new_player == state.player and new_enemy == state.enemy:
		return null
	return PuzzleState.new(new_player, new_enemy)
	
static func solve(horizontal_walls: Array, vertical_walls: Array, start_state: PuzzleState, goal: Vector2i) -> Dictionary:
	var queue: Array = []
	var visited: Dictionary = {}
	queue.append([start_state, []])
	visited[start_state.to_key()] = true
	var death_traps: int = 0
	while not queue.is_empty():
		var current_item = queue.pop_front()
		var current_state: PuzzleState = current_item[0]
		var path: Array = current_item[1]
		
		if current_state.player == goal:
			return {"solvable": true, "moves": path.size(), "path": path, "traps": death_traps}
		for direction_name in DIRECTIONS:
			var direction_vector: Vector2i = DIRECTIONS[direction_name]
			var next_state = step(current_state, direction_vector, horizontal_walls, vertical_walls)
			
			if next_state == null:
				death_traps += 1
				continue
			var key = next_state.to_key()
			if not visited.has(key):
				visited[key] = true
				var new_path = path.duplicate()
				new_path.append(direction_name)
				queue.append([next_state, new_path])
			
	return {"solvable": false, "moves": 0, "path": [], "traps": death_traps}
	
static func generate(size: int = 6, min_moves: int = 6, wall_density: float = 0.25, max_attempts: int = 1000) -> Node:
	var best_level: Dictionary = {}
	var best_score: int = -1

	# Liste aller möglichen Innenwände
	var inner_h_edges: Array[Vector2i] = []
	for y in range(1, size):
		for x in range(size):
			inner_h_edges.append(Vector2i(x, y))

	var inner_v_edges: Array[Vector2i] = []
	for y in range(size):
		for x in range(1, size):
			inner_v_edges.append(Vector2i(x, y))

	var total_inner_edges = inner_h_edges.size() + inner_v_edges.size()
	var walls_to_place = int(total_inner_edges * wall_density)

	# Liste aller Zellen für Start-/Zielpositionen
	var cells: Array[Vector2i] = []
	for y in range(size):
		for x in range(size):
			cells.append(Vector2i(x, y))

	for attempt in range(max_attempts):
		var horizontal_walls : Array = create_matrix(size + 1, size)
		var vertical_walls : Array = create_matrix(size, size + 1)

		# Zufällige Innenwände streuen
		var all_edges: Array[Dictionary] = []
		for e in inner_h_edges:
			all_edges.append({"type": "H", "pos": e})
		for e in inner_v_edges:
			all_edges.append({"type": "V", "pos": e})
		all_edges.shuffle()

		for i in range(walls_to_place):
			var edge = all_edges[i]
			if edge["type"] == "H":
				horizontal_walls[edge["pos"].y][edge["pos"].x] = 1
			else:
				vertical_walls[edge["pos"].y][edge["pos"].x] = 1

		# Start- & Zielpositionen wählen
		var shuffled_cells = cells.duplicate()
		shuffled_cells.shuffle()
		var p_start = shuffled_cells[0]
		var e_start = shuffled_cells[1]
		var goal = shuffled_cells[2]

		var start_state = PuzzleState.new(p_start, e_start)
		var sol = solve(horizontal_walls, vertical_walls, start_state, goal)

		if sol["solvable"]:
			var score = (sol["moves"] * 100) + (sol["traps"] * 2)

			if sol["moves"] >= min_moves:
				return createNodeFile(size, horizontal_walls, vertical_walls, goal, p_start, e_start)
				#return {
				#	"n": size,
				#	"h_walls": horizontal_walls,
				#	"v_walls": vertical_walls,
				#	"player_start": p_start,
				#	"enemy_start": e_start,
				#	"goal": goal,
				#	"solution": sol
				#}

			if score > best_score:
				best_score = score
				best_level = {
					"n": size,
					"h_walls": horizontal_walls,
					"v_walls": vertical_walls,
					"player_start": p_start,
					"enemy_start": e_start,
					"goal": goal,
					"solution": sol
				}
	
	return createNodeFile(size, best_level.get("h_walls"), best_level.get("v_walls"), best_level.get("goal"), best_level.get("player_start"), best_level.get("enemy_start"))
	
static func createNode(size: int, horizontal_walls: Array, vertical_walls: Array, goal: Vector2i, player_start: Vector2i, enemy_start: Vector2i) -> Node:
	var level_node = Node.new()
	level_node.name = "GeneratedLevel"
	level_node.set_meta("HORIZONTAL_WALLS", horizontal_walls)
	level_node.set_meta("VERTICAL_WALLS", vertical_walls)
	level_node.set_meta("GOAL_POSITION", goal)
	level_node.set_meta("PLAYER_START", player_start)
	level_node.set_meta("ENEMY_START", player_start)
	level_node.set_meta("GRID_SIZE", size)
	level_node.set_meta("CELL_SIZE", 60)
	return level_node
	
static func createNodeFile(size: int, horizontal_walls: Array, vertical_walls: Array, goal: Vector2i, player_start: Vector2i, enemy_start: Vector2i) -> Node:
	var level_node = LevelData.new()
	level_node.GRID_SIZE = size
	level_node.HORIZONTAL_WALLS = horizontal_walls
	level_node.VERTICAL_WALLS = vertical_walls
	level_node.PLAYER_START = player_start
	level_node.ENEMY_START = enemy_start
	level_node.GOAL_POSITION = goal
	return level_node
	
	
