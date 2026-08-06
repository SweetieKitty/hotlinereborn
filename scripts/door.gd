extends Node2D

@onready var sprite_top: Sprite2D = get_node_or_null("DoorCloseTop")
@onready var sprite_bottom: Sprite2D = get_node_or_null("DoorCloseBottom")
@onready var sprite_right: Sprite2D = get_node_or_null("DoorCloseRight")
@onready var sprite_left: Sprite2D = get_node_or_null("DoorCloseLeft")

var is_open: bool = false
var current_direction: String = "top"

func setup_direction(dir_key: String) -> void:
	current_direction = dir_key
	
	if sprite_top: sprite_top.visible = false
	if sprite_bottom: sprite_bottom.visible = false
	if sprite_right: sprite_right.visible = false
	if sprite_left: sprite_left.visible = false

	match dir_key:
		"top":
			if sprite_top: sprite_top.visible = true
		"bottom":
			if sprite_bottom: sprite_bottom.visible = true
		"left":
			if sprite_left:
				sprite_left.visible = true
				sprite_left.rotation_degrees = 90
		"right":
			if sprite_right:
				sprite_right.visible = true
				sprite_right.rotation_degrees = 90

func set_open(open_state: bool) -> void:
	is_open = open_state
	visible = not open_state
	if not open_state:
		setup_direction(current_direction)
