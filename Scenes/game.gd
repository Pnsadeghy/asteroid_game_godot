extends Node2D

@onready var lasers = $Lasers
@onready var astroids = $Astroids
@onready var hud = $UI/HUD
@onready var player = $Player
@onready var player_respwn_pos = $PlayerRespawnPos
@onready var player_spawn_area = $PlayerRespawnPos/PlayerSpawnArea

@onready var laser_sound = $LaserSound
@onready var astroid_sound = $AstoidHitSound
@onready var player_died_sound = $PlayerDiedSound

var astroid_prefab = preload("res://Entities/Astroid/astroid.tscn")

var score := 0:
	set(value):
		score = value
		hud.score = value
		
var lives: int:
	set(value):
		lives = value
		hud.init_lives(value)

func _ready():
	score = 0
	lives = 3
	
	for astroid in astroids.get_children():
		astroid.connect("exploded", _on_astroid_exploded)

func _process(delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _on_player_laser_shot(laser):
	laser_sound.play()
	lasers.add_child(laser)

func _on_astroid_exploded(pos, size, points):
	astroid_sound.play()
	score += points
	
	match size:
		Astroid.AstroidSize.LARGE:
			spawn_astroid(pos, Astroid.AstroidSize.MEDIUM)
			spawn_astroid(pos, Astroid.AstroidSize.MEDIUM)
			pass
		Astroid.AstroidSize.MEDIUM:
			spawn_astroid(pos, Astroid.AstroidSize.SMALL)
			spawn_astroid(pos, Astroid.AstroidSize.SMALL)
			spawn_astroid(pos, Astroid.AstroidSize.SMALL)
			pass
		Astroid.AstroidSize.SMALL:
			pass
	
func spawn_astroid(pos, size):
	var astroid = astroid_prefab.instantiate()
	astroid.global_position = pos
	astroid.size = size
	astroid.connect("exploded", _on_astroid_exploded)
	# astroid.add_child(astroid)
	# better to use bellow one to manage physics better
	astroids.call_deferred("add_child", astroid)

func _on_player_died():
	lives -= 1
	player_died_sound.play()
	player.global_position = player_respwn_pos.global_position
	if lives <= 0:
		await get_tree().create_timer(1).timeout
		$UI/GameOverScreen.visible = true
	else:
		await get_tree().create_timer(1).timeout
		while !player_spawn_area.is_empty:
			await get_tree().create_timer(0.1).timeout
		player.respawn()

func _on_restart_button_pressed():
	get_tree().reload_current_scene()
