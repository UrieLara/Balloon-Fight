extends Node2D

onready var label = $HUD/GameOverLabel
var enemies = []

func _ready():
	enemies = get_tree().get_nodes_in_group("Enemies")
	$"Music/start level".play()

func on_enemy_parachute(enemy):
	pass
		
func on_enemy_defeated(enemy):
	enemies.erase(enemy)
	if enemies.empty():
		win()
		
func win():
	label.text = "Win"
	label.show()
	$Music/win.play()
	
func game_over():
	label.text = "Game Over"
	label.show()
	$Music/loose.play()
