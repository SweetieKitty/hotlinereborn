extends Area2D

@export var speed: float = 800.0
@export var damage: float = 30.0

func _physics_process(delta: float) -> void:
	# Куля летить у напрямку, куди дивиться
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
