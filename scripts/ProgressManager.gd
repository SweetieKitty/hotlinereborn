extends Node

var current_stage: int = 1
var max_stages: int = 4

func get_random_rooms_count() -> int:
	# Рандомно від 5 до 8 кімнат на будь-якому поверсі
	return randi_range(5, 8)

func next_stage() -> void:
	current_stage += 1
	if current_stage > max_stages:
		print("ГРА ПРОЙДЕНА! ВСІ ПОВЕРХИ ЗАЧИЩЕНО!")
		current_stage = 1
	get_tree().reload_current_scene()
