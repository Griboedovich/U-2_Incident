extends Node2D

@export var scroll_speed: int = 400
@export var display_atmosphere: bool = true
@export var gap:float = 1

@onready var strip_1: Node2D = $BackgroundStrip1
@onready var strip_2: Node2D = $BackgroundStrip2

@onready var bg_size: Vector2 = (
	strip_1.get_child(0).get_texture().get_size()
)

var is_freezing: bool = false

func _ready() -> void:
	strip_1.position.y -= bg_size.y * 3 + gap
	strip_2.position.y += strip_1.position.y - bg_size.y * 4 + gap
	if (not display_atmosphere):
		$Atmosphere.hide()

func _process(delta: float) -> void:
	if not is_freezing:
		background_moving(delta)

func background_moving(delta: float) -> void:
	var bg_moving: float = scroll_speed * delta
	
	strip_1.position.y += bg_moving
	strip_2.position.y += bg_moving
	
	if strip_1.position.y > bg_size.y:
		strip_1.position.y = strip_2.position.y - bg_size.y * 4 + gap
	elif strip_2.position.y > bg_size.y:
		strip_2.position.y = strip_1.position.y - bg_size.y * 4 + gap

func freeze() -> void:
	is_freezing = true
func unfreeze() -> void:
	is_freezing = false
