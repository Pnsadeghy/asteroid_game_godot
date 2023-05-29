extends Area2D

class_name Astroid

signal exploded(pos, size, points)

enum AstroidSize{LARGE, MEDIUM, SMALL}

@export var size := AstroidSize.LARGE

var speed := 0
var rotate_speed := 0.0
var movement_vector := Vector2(0, -1)
var movement_rotation
var screen_size: Vector2
var shape_size
var points: int:
	get:
		match size:
			AstroidSize.LARGE:
				return 100
			AstroidSize.MEDIUM:
				return 50
			AstroidSize.SMALL:
				return 25
			_:
				return 0

func _ready():
	match size:
		AstroidSize.LARGE:
			speed = randf_range(50, 100)
			rotate_speed = 0.3
			$Sprite2D.texture = preload("res://Assets/Sprites/meteorGrey_big4.png")
			# $CollisionShape2D.shape = preload("res://Entities/Astroid/resources/astroid-big-collision.tres")
			$CollisionShape2D.set_deferred("shape", preload("res://Entities/Astroid/resources/astroid-big-collision.tres"))
			pass
		AstroidSize.MEDIUM:
			speed = randf_range(100, 150)
			rotate_speed = 0.4
			$Sprite2D.texture = preload("res://Assets/Sprites/meteorGrey_med2.png")
			$CollisionShape2D.set_deferred("shape", preload("res://Entities/Astroid/resources/astroid-mid-collision.tres"))
			pass
		AstroidSize.SMALL:
			speed = randf_range(100, 200)
			rotate_speed = 0.5
			$Sprite2D.texture = preload("res://Assets/Sprites/meteorGrey_tiny1.png")
			$CollisionShape2D.set_deferred("shape", preload("res://Entities/Astroid/resources/astroid-small-collision.tres"))
			pass
	
	rotation = randf_range(0, 2*PI)
	movement_rotation = rotation
	speed = randf_range(speed, speed + 50)
	screen_size = get_viewport_rect().size
	shape_size = $CollisionShape2D.shape.radius

func _physics_process(delta):
	global_position += movement_vector.rotated(movement_rotation) * speed * delta
	rotate(rotate_speed * delta)
	
	if global_position.y + shape_size < 0:
		global_position.y = screen_size.y + shape_size
	elif global_position.y - shape_size > screen_size.y:
		global_position.y = -shape_size
		
	if global_position.x + shape_size < 0:
		global_position.x = screen_size.x + shape_size
	elif global_position.x - shape_size > screen_size.x:
		global_position.x = -shape_size
	
func explode():
	exploded.emit(global_position, size, points)
	queue_free()


func _on_body_entered(body):
	if body is Player:
		body.die()
