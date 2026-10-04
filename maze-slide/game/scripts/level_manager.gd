extends Node

const LEVELS = [
	preload("res://levels/level_01.gd"),
	preload("res://levels/level_02.gd"),
	preload("res://levels/level_03.gd"),
	preload("res://levels/level_04.gd"),
	preload("res://levels/level_05.gd")
]

var current_level_index: int = 0

var is_random_level = false

func get_current_level():
	return LEVELS[current_level_index]


func set_level(level_index: int):
	if level_index >= LEVELS.size():
		return

	current_level_index = level_index

func get_random_level():
	return is_random_level
	
func set_random_level(is_random: bool):
	is_random_level = is_random
	
func get_level_count() -> int:
	return LEVELS.size()
