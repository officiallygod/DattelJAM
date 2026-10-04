extends CharacterBody2D

@onready var ray = $RayCast2D
@export var tile_size : int = 16
@export var movement_speed : float = 0.2

func _ready() -> void:
	position = position.snapped(Vector2(tile_size, tile_size))

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("up"):
		velocity.y = -movement_speed

	if Input.is_action_just_pressed("down"):
		velocity.y = movement_speed
		
	if Input.is_action_just_pressed("right"):
		velocity.x = movement_speed
		
	if Input.is_action_just_pressed("left"):
		velocity.x = -movement_speed

	move_and_slide()
