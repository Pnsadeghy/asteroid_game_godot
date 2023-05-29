extends CharacterBody2D

class_name Player

signal laser_shot(laser)
signal died

@export var acceleration := 10.0
@export var max_speed := 350.0
@export var rotation_speed := 250.0

@onready var marker = $ProjectileMarker
@onready var cshape = $CollisionShape2D
@onready var sprite = $Sprite2D

var screen_size: Vector2
var shoot_cooldown = false
var rate_of_fire = 0.5
var is_alive := true

var laser_prefab = preload("res://Entities/Laser/laser.tscn")

func _ready():
	screen_size = get_viewport_rect().size
	
func _process(delta):
	if !is_alive: return
	
	if Input.is_action_pressed("shoot"):
		if !shoot_cooldown:
			shoot_laser()
			shoot_cooldown = true
			await get_tree().create_timer(rate_of_fire).timeout
			shoot_cooldown = false
			
func _physics_process(delta):
	if !is_alive: return
	
	move_calculate(delta)
	check_position()	
		
func move_calculate(delta):
	var input_vector := Vector2(0, Input.get_axis("move_forward", "move_backward"));
	
	velocity += input_vector.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)
	
	if Input.is_action_pressed("rotate_right"):
		rotate(deg_to_rad(rotation_speed * delta))
	elif Input.is_action_pressed("rotate_left"):
		rotate(deg_to_rad(-rotation_speed * delta))
	
	if input_vector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, 3)
	
	move_and_slide()
	
func check_position():
	# back shape to view if it exit
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
		
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0
		
func shoot_laser():
	var laser = laser_prefab.instantiate()
	laser.global_position = marker.global_position
	laser.rotation = rotation
	laser_shot.emit(laser)
		
func die():
	if !is_alive: return
	is_alive = false
	sprite.hide()
	cshape.set_deferred("disabled", true)
	died.emit()
	
func respawn():
	if is_alive: return
	velocity = Vector2.ZERO
	rotation = 0
	is_alive = true
	sprite.show()
	cshape.set_deferred("disabled", false)
	
