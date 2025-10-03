extends "res://scripts/character.gd"

var balloons = 2
var x = 0
var y = 0

func _ready():
	randomize() 
	animations.play("Blow-pink")
	x  = global_position.x
	y = global_position.y
	print("ready")

func _on_Animations_Enemy_animation_finished():
	pass
	print("finished")
	
func _physics_process(delta):
	teletransport()
	move_enemy()

func up():
	pass
	

func _on_Timer_timeout():
	random_movement()
	
func move_enemy():
	pass
	
	
func random_movement():
#	print("x:" + str(x))
#	print("y:" + str(x))
	
	var random_mov = round(rand_range(-10, 10))
	var random_direction = round(rand_range(-5, 5))
	
	if random_direction <= 0:
		x = x + random_mov*2
	else:
		y = y + random_mov*2
	
	
