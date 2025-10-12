extends CanvasLayer

onready var sound_score = $"../Music/score"

onready var scorelabel = $ScoreLabel
onready var enemylabel = $ScoreEnemy

var score_scene = preload("res://Scores.tscn") 
var score_instance
var score = 0

func _ready():
	init_score()

func init_score():
	scorelabel.text = " %06d" % 0
	
func update_score(value, enemy_position):
	score += value
	sound_score.play()
	scorelabel.text = " %06d" % score
	
	score_instance = score_scene.instance()
	add_child(score_instance)
	score_instance.setup(value, enemy_position)
#	enemylabel.text = str(value)
#	enemylabel.visible = true
#	enemylabel.rect_global_position = Vector2(enemy_position.x-15, enemy_position.y-30)
#
