extends Node2D

onready var label = $HUD/GameOverLabel
var enemies = []

func _ready():
	enemies = get_tree().get_nodes_in_group("Enemies")
	print(enemies.size())
	$"Music/level song".play()
	
func on_enemy_defeated(enemy):
	enemies.erase(enemy)
	if enemies.empty():
		win()
		$Music/.play()
func win():
	label.text = "Win"
	label.show()

func game_over():
	label.text = "Game Over"
	label.show()
	$Music/loose.play()
