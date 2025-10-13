extends Node2D

onready var label = $HUD/GameOverLabel

func _ready():
	$"Music/start level".play()
			
func win():
	label.text = "You Win"
	label.show()
	$Music/win.play()
	
func game_over():
	label.text = "Game Over"
	label.show()
	$Music/loose.play()
