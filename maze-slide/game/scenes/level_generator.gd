extends Node2D
var size = 10

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
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var horizontal_walls : Array = create_matrix(size, size + 1)
	var vertical_walls : Array = create_matrix(size + 1, size)
	var goal = Vector2(randi() % 9, randi() % 9)
	var player
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
	
func create_matrix(n:int, m:int) -> Array:
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
	while true:
		if direction == Vector2i.UP:
			if(horizontal_walls[current_position.y][current_position.x] == 1):
				break
			current_position.y -= 1
		if direction == Vector2i.DOWN:
			if(vertical_walls[current_position.y + 1][current_position.x] == 1):
				break
				current_position.y += 1
		if direction == Vector2i.LEFT:
			if(vertical_walls[current_position.y][current_position.x] == 1):
				break
			current_position.y -= 1
		if direction == Vector2i.RIGHT:
			if(vertical_walls[current_position.y][current_position.x + 1] == 1):
				break
			current_position.y += 1
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
