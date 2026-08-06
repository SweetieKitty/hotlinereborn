extends Area2D

signal room_cleared

@export var is_boss_room: bool = false
@export var door_scene: PackedScene = preload("res://tscn/door.tscn")

var grid_pos: Vector2 = Vector2.ZERO
var is_cleared: bool = false
var active_enemies: int = 0

var spawned_doors := {}
var open_directions := {}

func setup_doors(has_top: bool, has_bottom: bool, has_left: bool, has_right: bool) -> void:
	if not is_node_ready():
		await ready

	open_directions = {
		"top": has_top,
		"bottom": has_bottom,
		"left": has_left,
		"right": has_right
	}

	if door_scene == null:
		print("АЛАРМ! door_scene дорівнює NULL в кімнаті ", name)
		return

	var marker_top = get_node_or_null("Doors/DoorTop")
	var marker_bottom = get_node_or_null("Doors/DoorBottom")
	var marker_left = get_node_or_null("Doors/DoorLeft")
	var marker_right = get_node_or_null("Doors/DoorRight")

	print("--- КІМНАТА ", name, " ---")
	print("Сусіди по генератору: TOP=", has_top, " BOT=", has_bottom, " LEFT=", has_left, " RIGHT=", has_right)
	print("Знайдені маркери: TOP=", marker_top != null, " BOT=", marker_bottom != null, " LEFT=", marker_left != null, " RIGHT=", marker_right != null)

	if has_top and marker_top: spawn_door_at("top", marker_top)
	if has_bottom and marker_bottom: spawn_door_at("bottom", marker_bottom)
	if has_left and marker_left: spawn_door_at("left", marker_left)
	if has_right and marker_right: spawn_door_at("right", marker_right)

	if is_cleared:
		set_all_doors_open(true)

func spawn_door_at(dir_key: String, marker: Node) -> void:
	var door_inst = door_scene.instantiate()
	marker.add_child(door_inst)
	door_inst.position = Vector2.ZERO
	
	# Авто-поворот тільки для бокових дверей
	if dir_key == "left" or dir_key == "right":
		door_inst.rotation_degrees = 90
	else:
		door_inst.rotation_degrees = 0
	
	if door_inst.has_method("setup_direction"):
		door_inst.setup_direction(dir_key)

	if door_inst.has_method("set_open"):
		door_inst.set_open(false)

	spawned_doors[dir_key] = door_inst

func set_all_doors_open(should_open: bool) -> void:
	for dir in spawned_doors:
		var door = spawned_doors[dir]
		if is_instance_valid(door) and door.has_method("set_open"):
			door.set_open(should_open)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if not is_cleared:
			lock_doors()

func lock_doors() -> void:
	set_all_doors_open(false)

func unlock_doors() -> void:
	is_cleared = true
	set_all_doors_open(true)
	room_cleared.emit()
