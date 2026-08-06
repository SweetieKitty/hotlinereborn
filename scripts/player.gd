extends CharacterBody2D

@export var speed: float = 300.0
@export var rotation_speed: float = 50.0
@export var max_hp: float = 100.0
var current_hp: float

# Налаштування стрільби:
@export var fire_rate: float = 0.15 # Затримка між пострілами (чим менше — тим швидше)
var can_shoot: bool = true

@export var bullet_scene: PackedScene 
@onready var gun_point: Node2D = $GunPoint

func _ready() -> void:
	current_hp = max_hp
	add_to_group("player")

func _physics_process(delta: float) -> void:
	# 1. Поворот
	smooth_rotate_to_mouse(delta)
	
	# 2. Рух
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	move_and_slide()
	
	# 3. Стрільба (затиснута ЛКМ, але з кулдауном)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_shoot:
		shoot()

func smooth_rotate_to_mouse(delta: float) -> void:
	var target_angle = global_position.angle_to_point(get_global_mouse_position())
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)

func shoot() -> void:
	if bullet_scene == null:
		print("УВАГА: Не вибрано bullet_scene в Inspector!")
		return
		
	can_shoot = false # Блокуємо стрільбу
	
	var projectile = bullet_scene.instantiate()
	projectile.global_position = gun_point.global_position
	projectile.rotation = rotation
	get_parent().add_child(projectile)
	
	# Таймер перезарядки пострілу
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true # Знову можна стріляти

func take_damage(amount: float) -> void:
	current_hp -= amount
	print("ХП Гравця: ", current_hp)
	if current_hp <= 0:
		queue_free()
