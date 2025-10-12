extends Control
onready var menu = $Menu
onready var controls = $Controls
onready var music = $"main menu"

var GAME = preload("res://Main.tscn")

func _ready():
	music.play()

func _input(event):
	if Input.is_action_just_pressed("controls"):
		show_controls()
		
	if Input.is_action_just_pressed("play"):
		start_game()

func show_controls():
	for child in menu.get_children():
		child.visible = false
		
	for child in controls.get_children(): 
		child.visible = true
	
func start_game():
	music.stop()
	get_tree().change_scene_to(GAME)
	pass	
		
