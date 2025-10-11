extends "res://scripts/character.gd"

enum state {blowing, idle, parachute, flying, dead}
var balloons = 1
var x = 0
var y = 0

var score_amount = 0
export var propulsion = 1.0
export var speed = 1.0
export var min_y = 80
var hud

var actual_state = state.blowing
var vec_velocity = Vector2.ZERO 

var player = null # Referencia al nodo Player
var score = null


func _ready():
	randomize() 
	animations.play("Blow-pink")
	x  = global_position.x
	y = global_position.y
	player = get_tree().get_root().find_node("Player", true, false)
	
	hud = get_tree().get_root().find_node("HUD", true, false)
	

	
	if player:
		player.connect("player_died", self, "_on_Player_died")

func _on_Player_died():
	x = global_position.x
	y = global_position.y
	game_over()
	
func _physics_process(delta):
	teletransport()
	vec_velocity.y += apply_gravity(delta)
	vec_velocity = move_and_slide(vec_velocity, Vector2.UP)
	if actual_state == state.parachute:
		if vec_velocity.y > Constants.MAX_FALLING_VELOCITY:
			vec_velocity.y = Constants.MAX_FALLING_VELOCITY
		
		
func move (direction, flip):
	vec_velocity.x = lerp(vec_velocity.x, direction*Constants.MAX_SPEED*speed, Constants.ACCELERATION_FACTOR)
	animations.flip_h = flip	
	
func fly ():
	vec_velocity.y = Constants.FLY_IMPULSE
			
func _on_StartFly_timeout():
	actual_state = state.flying
	$TimerX.start()
	$TimerY.start()
	animations.play("Fly-pink")
	
func _on_TimerY_timeout():
	var prob = 5 #20% probabilidad
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

func _on_Hitbox_area_entered(area): #bird-body
	if actual_state == state.blowing:
		hud.add_score(750)	
		die()
		
	if area.name == "Death Area":
		queue_free()
	
func _on_Hurtbox_area_entered(area): #balloons or parachute
	match actual_state:
		state.flying:
			hud.add_score(500)	
			open_parachute()
			
		state.parachute:
			hud.add_score(1000)
			die()
			
func open_parachute():
	actual_state = state.parachute
	animations.play("Parachute-pink")
	$TimerX.stop()
	$TimerY.stop()
	self.set_collision_mask_bit(Constants.MASK_FOREGROUND - 1, false)
	$Hitbox.set_deferred("disabled", true)

func die():
	actual_state = state.dead
	$StartFly.stop()
	$TimerX.stop()
	$TimerY.stop()
	animations.play("Die")
	self.set_collision_mask_bit(Constants.MASK_FOREGROUND - 1, false)
	$Hitbox.set_deferred("disabled", true)	
		
func game_over():
	global_position = Vector2(x, y)
	$TimerX.stop()
	$TimerY.stop()
	animations.stop()
	set_physics_process(false)
	
	
			
