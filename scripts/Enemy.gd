extends "res://scripts/character.gd"

onready var sound_exploded = $Sounds/exploded
onready var sound_fly = $Sounds/fly
onready var sound_die = $Sounds/die
onready var sound_parachute = $Sounds/parachute

enum state {blowing, idle, parachute, flying, dead}
var balloons = 1
var x = 0
var y = 0

var score_amount = 0
export var propulsion = 1.0
export var speed = 1.0
export var min_y = 80
var hud
var playing = true

var actual_state = state.blowing
var vec_velocity = Vector2.ZERO 

var node_player = null


func _ready():
	randomize() 
	animations.play("Blow-pink")
	x  = global_position.x
	y = global_position.y
	node_player = get_tree().get_root().find_node("Player", true, false)
	
	hud = get_tree().get_root().find_node("HUD", true, false)

	if node_player:
		node_player.connect("player_died", self, "_on_Player_died")

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
	$Timers/TimerX.start()
	$Timers/TimerY.start()
	animations.play("Fly-pink")
	
func _on_TimerY_timeout():
	var prob = 6 #16% probabilidad
	var flight_impulse = Constants.FLY_IMPULSE * propulsion
	
	if global_position.y > Constants.MIN_FLY_ALTITUDE or is_on_floor():
		prob = 1
	
	var fly = randi() % prob == 0 
	
	if fly:
		vec_velocity.y =  flight_impulse
		play_sound(sound_fly)
	
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
		hud.update_score(750, global_position)	
		die()
		
	if area.name == "Death Area":
		queue_free()
		game_over()
	
func _on_Hurtbox_area_entered(_area): #balloons or parachute
	if playing:
		match actual_state:
			state.flying:
				hud.update_score(500, global_position)	
				play_sound(sound_exploded)
				open_parachute()
				
			state.parachute:
				hud.update_score(1000, global_position)
				die()
			
func open_parachute():
	actual_state = state.parachute
	animations.play("Parachute-pink")
	stop_timers()
	stop_collision()
	play_sound(sound_parachute)
	
func die():
	actual_state = state.dead
	stop_timers()
	stop_interactivity()
	animations.play("Die")
	get_parent().get_parent().call_deferred("on_enemy_defeated", self)
	play_sound(sound_die)

func game_over():
	playing = false
	stop_interactivity()
	global_position = Vector2(x, y)
	animations.stop()
	set_physics_process(false)
	stop_sounds()
	stop_timers()
			
func stop_timers():
	$Timers/StartFly.stop()
	$Timers/TimerX.stop()
	$Timers/TimerY.stop()
	
func stop_collision():
	self.set_collision_mask_bit(Constants.MASK_FOREGROUND-1, false)
	self.set_collision_mask_bit(1, false)
	$Hitbox.set_deferred("disabled", true)
	
func stop_interactivity():
	stop_collision()
	$".".set_deferred("disabled", true)
		
func play_sound(new_sound):
	if sound_parachute.playing:
		sound_parachute.stop()
	new_sound.play()

func stop_sounds():
	var childrens = $Sounds.get_children()
	for child in childrens:
		if child is AudioStreamPlayer:
			child.stop()
	
			
