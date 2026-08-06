extends Control

@export var room_icon_size: Vector2 = Vector2(24, 16)
@export var spacing: Vector2 = Vector2(4, 4)

var room_nodes: Dictionary = {}
var player_marker: ColorRect
var min_grid_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("minimap")

func setup_map(grid_positions: Array[Vector2], boss_pos: Vector2) -> void:
	for child in get_children():
		child.queue_free()
	room_nodes.clear()

	var min_x = 0
	var min_y = 0
	for pos in grid_positions:
		if pos.x < min_x: min_x = pos.x
		if pos.y < min_y: min_y = pos.y
	min_grid_offset = Vector2(min_x, min_y)

	for grid_pos in grid_positions:
		var rect = ColorRect.new()
		rect.custom_minimum_size = room_icon_size
		rect.size = room_icon_size
		
		var normalized_pos = grid_pos - min_grid_offset
		rect.position = Vector2(
			normalized_pos.x * (room_icon_size.x + spacing.x),
			normalized_pos.y * (room_icon_size.y + spacing.y)
		)
		
		if grid_pos == Vector2.ZERO:
			rect.color = Color.GREEN
		elif grid_pos == boss_pos:
			rect.color = Color.RED
		else:
			rect.color = Color.DARK_GRAY
			
		add_child(rect)
		room_nodes[grid_pos] = rect

	player_marker = ColorRect.new()
	player_marker.size = Vector2(6, 6)
	player_marker.color = Color.WHITE
	add_child(player_marker)
	
	update_player_position(Vector2.ZERO)

func update_player_position(current_grid_pos: Vector2) -> void:
	if player_marker and room_nodes.has(current_grid_pos):
		var target_room = room_nodes[current_grid_pos] as ColorRect
		player_marker.position = target_room.position + (room_icon_size / 2) - (player_marker.size / 2)
