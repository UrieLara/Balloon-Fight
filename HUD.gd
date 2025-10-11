extends CanvasLayer
onready var scorelabel = $ScoreLabel

var score = 0
var label: Label

func _ready():
	label = get_node("ScoreLabel") 
	
	if label == null:
		print("¡ERROR! no se encontró el label.")
		return 
		
	print(label)
	update_score(0)
	
	 

func add_score(amount):
	score += amount
	update_score(score)
	print(score)

func update_score(value):
	scorelabel.text = " %06d" % value
