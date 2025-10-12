extends "res://scripts/character.gd"
signal player_died

onready var sound_exploded = $Sounds/exploded
onready var sound_fly = $Sounds/fly

var balloons = 2
var vec_velocity = Vector2.ZERO
var direction_x = 0
var x = 0
var y = 0

enum player {idle, moving, flying,  dead}
enum states {idle, left, right, fly}

var actual_player_state = player.idle
var immunity = true

var enemies_beaten = []
var can_move = true
		
func _physics_process(delta):
	move_player()
	teletransport()
	vec_velocity.y += apply_gravity(delta)	
	
	if actual_player_state == player.dead:
			vec_velocity.x = 0
	vec_velocity = move_and_slide(vec_velocity, Vector2.UP) 
	
func event_key():
	if Input.is_action_just_pressed("fly"):
		return states.fly	
			
	if Input.is_action_pressed("left"):
		return states.left
		
	if Input.is_action_pressed("right"):
		return states.right
	
	return states.idle
	
	
func move_player():
	var event_k 
	if can_move:
		event_k = event_key()

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
				player.flying:
					actual_player_state = player.idle		
	play_animation(actual_player_state)

func move (direction, flip):
	direction_x = direction
	animations.flip_h = flip	
	actual_player_state = player.moving
	
	vec_velocity.x = lerp(vec_velocity.x, direction_x*Constants.MAX_SPEED, Constants.ACCELERATION_FACTOR)
	#vec_velocity.x = direction_x*Constants.MAX_SPEED
	
func fly ():
	vec_velocity.y = Constants.FLY_IMPULSE
	actual_player_state = player.flying
	sound_fly.play()
	
func stop():
	vec_velocity.x = lerp(vec_velocity.x, 0, Constants.FRICTION)
	
func play_animation(state):
	if balloons > 0:
		var bal_sufix = "-%db" % balloons

		match state:
			player.flying:
				animations.play("Fly" + bal_sufix)
				
			player.idle:
				if is_on_floor():
					if abs(vec_velocity.x) > 5:
						animations.play("Brake" + bal_sufix)
					elif abs(vec_velocity.x) <= 5:
						animations.play("Idle" + bal_sufix)
				elif vec_velocity.y > 0:
					animations.play("Idle-sky" + bal_sufix)

			player.moving:
				if is_on_floor():
					animations.play("Run" + bal_sufix)
				elif vec_velocity.y > 0:
					animations.play("Idle-sky" + bal_sufix)

func _on_playerballoons_area_entered(area):
	var enemy_node = area.get_parent().name
	
	if not enemy_node in enemies_beaten:
		if !immunity and balloons >= 1:
			if is_on_floor():
				animations.play("Popped-idle")
			else:
				animations.play("Popped-air")

			balloons -= 1
			sound_exploded.play()
			
			$TimerImmunity.wait_time = 1.0
			$TimerImmunity.start()
			
		if balloons <= 0:
			die()
			game_over()

func _on_Hitbox_area_entered(area):
	var enemy_node = area.get_parent().name
	
	if not enemy_node in enemies_beaten:
		enemies_beaten.append(enemy_node)
	
	if actual_player_state!= player.dead:
		if area.name == "Death Area":
			game_over()
		
func _on_TimerImmunity_timeout():
	immunity = false

func die():
	actual_player_state = player.dead
	animations.play("Die")
	vec_velocity.y = Constants.FLY_IMPULSE
	game_over()
	
func game_over():
	emit_signal("player_died")
	stop()
	stop_interactivity()
	stop_sounds()
	get_parent().get_parent().call_deferred("game_over")
	

func stop_interactivity():
	can_move = false
	self.set_collision_layer(0)
	self.set_collision_mask(0)
	$"player-collision".set_deferred("disabled", true)
	$Hitbox.set_deferred("disabled", true)
	$Hurtbox.set_deferred("disabled", true)
	
func stop_sounds():
	var childrens = $Sounds.get_children()
	for child in childrens:
		if child is AudioStreamPlayer:
			child.stop()
