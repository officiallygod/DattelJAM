extends Node
var music_player: AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	add_child(music_player)
	
func play_music(stream: AudioStream, volume_db: float = 0.0) -> void:
	if music_player.stream == stream and music_player.playing:
		return
	music_player.stream = stream
	music_player.volume_db = volume_db
	music_player.play()
	
