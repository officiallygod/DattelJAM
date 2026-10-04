extends Node

const LEVELS = [
	preload("res://levels/level_01.gd"),
	preload("res://levels/level_02.gd"),
	preload("res://levels/level_03.gd")
]

var current_level_index: int = 0


func get_current_level():
	return LEVELS[current_level_index]


func set_level(level_index: int):
	if level_index >= LEVELS.size():
		return

	current_level_index = level_index


func get_level_count() -> int:
	return LEVELS.size()
