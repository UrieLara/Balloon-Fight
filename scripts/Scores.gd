extends Control

onready var timer = $TimerShowScore
onready var score_label = $FloatingScoreLabel

func setup(value, position):
	score_label.text = str(value)
	score_label.rect_global_position = Vector2(position.x - 15, position.y - 30)
	score_label.visible = true
	timer.start()

func _on_TimerShowScore_timeout():
	queue_free()
