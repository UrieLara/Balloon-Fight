extends "res://scripts/character.gd"

var balloons = 2
var x = 0
var y = 0

export var propulsion = 1.0
export var speed = 1.0
export var min_y = 80
var vec_velocity = Vector2.ZERO 

func _ready():
	randomize() 
	animations.play("Blow-pink")
	x  = global_position.x
	y = global_position.y
	print("inicio - x:"+str(x)+", y:"+str(y))
	
func _physics_process(delta):
	teletransport()
	vec_velocity.y += apply_gravity(delta)
	vec_velocity = move_and_slide(vec_velocity, Vector2.UP)
	
func move (direction, flip):
	vec_velocity.x = lerp(vec_velocity.x, direction*Constants.MAX_SPEED*speed, Constants.ACCELERATION_FACTOR)
	animations.flip_h = flip	
	
func fly ():
	vec_velocity.y = Constants.FLY_IMPULSE
			
func _on_StartFly_timeout():
	$TimerX.start()
	$TimerY.start()
	
func _on_TimerY_timeout():
	print("global position y = "+str(global_position.y))
	print("vec_y: "+str(vec_velocity.y))
	var prob = 3 #33% probabilidad
	var flight_impulse = Constants.FLY_IMPULSE * propulsion
	
	if global_position.y > Constants.MIN_FLY_ALTITUDE or is_on_floor():
		prob = 1
	
	var fly = randi() % prob == 0 
	
	if fly:
		vec_velocity.y =  flight_impulse
	
	if global_position.y <= min_y:
		flight_impulse = 0


func _on_TimeX_timeout():
	var mov_direction = randi() % 2 == 0 #20% probabilidad
	var direction = 1
	var flip = true
	
	if mov_direction:
		direction *= -1
		flip = false

	move(direction, flip)

