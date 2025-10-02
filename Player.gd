extends KinematicBody2D
onready var animation_player = $Animations

var vec_velocity = Vector2.ZERO

const GRAVITY = 600 
const FLY_IMPULSE = -150
const FRICTION = 0.1
const MAX_WINDOW_X = 1024
const SIZE_PLAYER_X = 24


var balloons = 2

enum player {idle, moving, flying}
enum states {idle, left, right, fly}

var actual_player_state = player.idle

func _physics_process(delta):
	move_player()
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

func event_key():
	if Input.is_action_just_pressed("fly"):
		return states.fly	
			
	if Input.is_action_pressed("left"):
		return states.left
		
	if Input.is_action_pressed("right"):
		return states.right
	
	return states.idle
	
	
func move_player():
	var event_k = event_key()
	print(event_k)
	match event_k:
		states.fly:
			fly()
		states.left:
			move(-1, false)
		states.right:
			move(1, true)
		states.idle: 
			match actual_player_state:
				player.idle:
					stop()
				player.moving:
					actual_player_state = player.idle
						
	play_animation(actual_player_state)

func move (direction, flip):
	vec_velocity.x = lerp(vec_velocity.x, direction*200, 0.15)
	animation_player.flip_h = flip	
	actual_player_state = player.moving
	
func fly ():
	vec_velocity.y = FLY_IMPULSE
	actual_player_state = player.flying
	
func stop():
	vec_velocity.x = lerp(vec_velocity.x, 0, FRICTION)
	
	
func play_animation(state):
	var bal_sufix = "-%db" % balloons

	match state:
		player.idle:
			if is_on_floor():
				if abs(vec_velocity.x) > 5:
					animation_player.play("Brake" + bal_sufix)
				elif abs(vec_velocity.x) <= 5:
					animation_player.play("Idle" + bal_sufix)
			elif vec_velocity.y > 0:
				animation_player.play("Idle-sky" + bal_sufix)

		player.moving:
			if is_on_floor():
				animation_player.play("Run" + bal_sufix)
			elif vec_velocity.y > 0:
				animation_player.play("Idle-sky" + bal_sufix)

		player.flying:
			animation_player.play("Fly" + bal_sufix)
			
