extends Node2D

@export var player_scene: PackedScene
@export var minimap: Node

# Пул завантажених кімнат
var start_room_scene: PackedScene
var normal_room_scenes: Array[PackedScene] = []
var boss_room_scenes: Array[PackedScene] = []

var grid_size: Vector2 = Vector2(2100, 1200)
var occupied_positions: Array[Vector2] = []
var cleared_rooms: int = 0
var total_normal_rooms: int = 0
func _ready() -> void:
	var current_floor = ProgressManager.current_stage # Отримуємо номер поверху (1, 2 або 3)
	load_rooms_for_floor(current_floor)
	
	var total_rooms = ProgressManager.get_random_rooms_count()
	total_normal_rooms = total_rooms - 1
	
	print("--- ПОВЕРХ №", current_floor, " ---")
	print("Завантажено кімнат з папки: ", normal_room_scenes.size())
	
	generate_level(total_rooms)

# Автоматично витягує всі .tscn з папки floorX
func load_rooms_for_floor(floor_num: int) -> void:
	normal_room_scenes.clear()
	var folder_path = "res://tscn/OsamaRooms/floor" + str(floor_num) + "/"
	
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tscn"):
				var full_path = folder_path + file_name
				var room_res = load(full_path) as PackedScene
				if room_res:
					normal_room_scenes.append(room_res)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("ПОМИЛКА: Не вдалося відкрити папку ", folder_path)

	if normal_room_scenes.size() > 0:
		start_room_scene = normal_room_scenes[0]
		boss_room_scenes = normal_room_scenes

func generate_level(total_rooms: int) -> void:
	occupied_positions.clear()
	
	# СТАРТ ЗАВЖДИ Перший у масиві і ЗАВЖДИ суворо на Vector2.ZERO!
	# Це гарантує, що мінімапа зафарбує зеленим (0,0), і Осама буде там.
	var start_pos = Vector2.ZERO
	occupied_positions.append(start_pos)
	
	# 1. Будуємо решту сітки
	var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	while occupied_positions.size() < total_rooms:
		var random_existing = occupied_positions.pick_random()
		var dir = directions.pick_random()
		var new_pos = random_existing + dir
		
		# Перевіряємо, щоб не було накладання
		if not occupied_positions.has(new_pos):
			occupied_positions.append(new_pos)

	# 2. Спавнимо кімнати по їхніх РЕАЛЬНИХ координатах
	for i in range(occupied_positions.size()):
		var pos = occupied_positions[i]
		var is_start = (i == 0) # Тільки перший елемент у масиві є стартовим
		var is_boss = (i == occupied_positions.size() - 1)
		
		var selected_scene: PackedScene = null
		if is_start:
			selected_scene = start_room_scene
		elif is_boss:
			selected_scene = boss_room_scenes.pick_random()
		else:
			selected_scene = normal_room_scenes.pick_random()
			
		spawn_room_instance(pos, is_boss, is_start, selected_scene)

	# 3. Спавн гравця СУВОРО в старт (Vector2.ZERO)
	if player_scene:
		var player = player_scene.instantiate()
		add_child(player)
		# Гравець спавниться в центрі стартової кімнати (0,0)
		player.global_position = grid_size / 2.0

	# 4. Викликаємо ТВОЮ СТАРУ МІНІМАПУ, як у тебе було.
	# Вона просто зафарбує зеленим (0,0), і все буде гуд!
	if minimap and minimap.has_method("setup_map"):
		var boss_pos = occupied_positions.back()
		# Передаємо старий масив і позицію боса
		minimap.setup_map(occupied_positions, boss_pos)

func spawn_room_instance(grid_pos: Vector2, is_boss: bool, start_cleared: bool, scene_to_spawn: PackedScene) -> void:
	if scene_to_spawn == null:
		return
		
	var room = scene_to_spawn.instantiate()
	room.position = grid_pos * grid_size
	
	if "is_boss_room" in room:
		room.is_boss_room = is_boss
	
	if start_cleared:
		if "is_cleared" in room:
			room.is_cleared = true
	else:
		if room.has_signal("room_cleared"):
			room.room_cleared.connect(_on_room_cleared)
		
	add_child(room)
	
	var has_top = occupied_positions.has(grid_pos + Vector2.UP)
	var has_bottom = occupied_positions.has(grid_pos + Vector2.DOWN)
	var has_left = occupied_positions.has(grid_pos + Vector2.LEFT)
	var has_right = occupied_positions.has(grid_pos + Vector2.RIGHT)
	
	if room.has_method("setup_doors"):
		room.setup_doors(has_top, has_bottom, has_left, has_right)

func _on_room_cleared() -> void:
	cleared_rooms += 1
	print("Зачищено: ", cleared_rooms, "/", total_normal_rooms)
	if cleared_rooms >= total_normal_rooms:
		print("Усі звичайні кімнати пройдені! Прохід до Боса відкрито!")
