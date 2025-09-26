extends KinematicBody2D

var vec_velocity = Vector2.ZERO

export var GRAVITY = 100
export var FLY_IMPULSE = -100
var balloons = 2

enum state_player {ground, fly}

var actual_state = state_player.ground

func _physics_process(delta):
	get_event()
	vec_velocity.y += GRAVITY * delta
	move_and_slide(vec_velocity, Vector2.UP)
	
func get_event():
	if Input.is_action_just_pressed("fly"):
		vec_velocity.y = FLY_IMPULSE
		fly()
	
	if Input.is_action_just_pressed("left"):
		run(-1, false)
		
	if Input.is_action_just_pressed("right"):
		run(1, true)
	
func run (direction, flip):
	vec_velocity.x = lerp(vec_velocity.x, direction*200, 0.1)
	$Animations.flip_h = flip
	if balloons == 2:
		$Animations.play("Run-2b")	
	elif balloons == 1: 
		$Animations.play("Run-1b")	

func fly ():
	$Animations.play("Fly-2b")	

	
