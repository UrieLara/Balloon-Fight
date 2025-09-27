extends KinematicBody2D

var vec_velocity = Vector2.ZERO

const GRAVITY = 400 
const FLY_IMPULSE = -200
const FRICTION = 0.1
const MAX_WINDOW_X = 1024
const SIZE_PLAYER_X = 24


var balloons = 2

enum player {idle, moving}
enum states {idle, left, right, fly}

var actual_player_state = player.idle

func _physics_process(delta):
	set_player_state()
	teletransport()
	vec_velocity.y += GRAVITY * delta
	vec_velocity = move_and_slide(vec_velocity, Vector2.UP)
	
	if is_on_floor():
		vec_velocity.y = 0
	
	#	for i in get_slide_count():
#		var collision = get_slide_collision(i)
#		if collision:
#			print("Golpeaste:"+str(collision.collider.name))
	
		

func teletransport():
	if global_position.x < 0-SIZE_PLAYER_X:
		global_position.x = MAX_WINDOW_X
	elif global_position.x > MAX_WINDOW_X+SIZE_PLAYER_X:
		global_position.x = 0
	
func _process(delta):
	play_animations()

func event_key():
	if Input.is_action_just_pressed("fly"):
		return states.fly	
			
	if Input.is_action_pressed("left"):
		return states.left
		
	if Input.is_action_pressed("right"):
		return states.right
	
	return states.idle
	
func set_player_state():
	var event_k = event_key()

	match actual_player_state:
		player.idle:
			match event_k:
				states.fly:
					fly()
				states.left:
					move(-1, false)
				states.right:
					move(1, true)
				states.idle:
					stop()

		player.moving:
			match event_k:
				states.fly:
					fly()
				states.left:
					move(-1, false)
				states.right:
					move(1, true)
				states.idle:
						actual_player_state = player.idle


func move (direction, flip):
	vec_velocity.x = lerp(vec_velocity.x, direction*200, 0.15)
	$Animations.flip_h = flip	
	actual_player_state = player.moving
	
func fly ():
	vec_velocity.y = FLY_IMPULSE
	actual_player_state = player.moving
	
func stop():
	vec_velocity.x = lerp(vec_velocity.x, 0, FRICTION)
	
	
func play_animations():
	match actual_player_state:
		player.idle: 
			if is_on_floor():
				if abs(vec_velocity.x) > 5:
					if balloons == 2:
						$Animations.play("Brake-2b")	
					elif balloons == 1:
						$Animations.play("Brake-1b")
						
				if abs(vec_velocity.x) <= 3:
					if balloons == 2:
						$Animations.play("Idle-2b")	
					elif balloons == 1:
						$Animations.play("Idle-1b")
			
			if vec_velocity.y > 0:
				if balloons == 2:
					$Animations.play("Idle-sky-2b")	
				elif balloons == 1:
					$Animations.play("Idle-sky-1b")
		
		player.moving:
			if is_on_floor():
				if balloons == 2:
					$Animations.play("Run-2b")						
				elif balloons == 1: 
					$Animations.play("Run-1b")	
				
			else:
				if balloons == 2:
					$Animations.play("Fly-2b")	
				elif balloons == 1:
					$Animations.play("Fly-1b")	
				
	
