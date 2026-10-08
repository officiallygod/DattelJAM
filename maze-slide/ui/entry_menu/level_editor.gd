extends Control
@onready var search_bar: LineEdit = $Panel/VBoxContainer/LineEdit
@onready var level_list: VBoxContainer = $Panel/VBoxContainer/ScrollContainer/VBoxContainer
@onready var create_button: Button = $Panel/VBoxContainer/CreateLevelButton
const LEVELS_PATH: String = "user://levels/"
var all_levels
func _ready() -> void:
	refresh_level_list()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func refresh_level_list() -> void:
	all_levels = load_level_names_from_disk()
	populate_level_list(all_levels)

func load_level_names_from_disk() -> Array[String]:
	var level_names: Array[String] = []
	
	if not DirAccess.dir_exists_absolute(LEVELS_PATH):
		DirAccess.make_dir_recursive_absolute(LEVELS_PATH)
		return level_names
		
	var dir = DirAccess.open(LEVELS_PATH)
	if dir == null:
		push_error("Error while opening the directionary")
		return level_names
		
	dir.include_hidden = false
	dir.include_navigational = false
	
	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".json"):
			var clean_name = file_name.get_basename()
			level_names.append(clean_name)
	return level_names		
	
func populate_level_list(levels_to_display: Array[String]) -> void:
	for child in level_list.get_children():
		child.queue_free()
		
	for level_name in levels_to_display:
		var button = Button.new()
		button.text = level_name
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.clip_text = true
			
		level_list.add_child(button)	

func _on_line_edit_text_changed(new_text: String) -> void:
	var filter = new_text.strip_edges().to_lower()
	if filter == "":
		for button in level_list.get_children():
			button.visible = true
		return
	for button in level_list.get_children():
		if button is Button:
			button.visible = filter in button.text.to_lower()
			print(button.visible)
