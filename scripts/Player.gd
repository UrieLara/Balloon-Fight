extends "res://scripts/character.gd"
signal player_died

var balloons = 2
var vec_velocity = Vector2.ZERO
var direction_x = 0
var x = 0
var y = 0

var enemies_beaten = []
enum player {idle, moving, flying}
enum states {idle, left, right, fly}

var actual_player_state = player.idle
var immunity = true

var var_game_over = false

func _physics_process(delta):
	move_player()
	teletransport()
	vec_velocity.y += apply_gravity(delta)	
#	if !(is_on_floor()):
#		vec_velocity.x = direction_x*100
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
	if !var_game_over:
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
			
			$TimerImmunity.wait_time = 2.0
			$TimerImmunity.start()
			
		if balloons <= 0:
			die()

func _on_Hitbox_area_entered(area):
	var enemy_node = area.get_parent().name
	
	if enemy_node in enemies_beaten:
		print("esta en la lista:"+str(enemy_node))
	
	if area.name == "Death Area":
		print("inframundo player")
	else:
		enemies_beaten.append(enemy_node)

		
		
func die():
	stop()
	var_game_over = true
	emit_signal("player_died")
	animations.play("Die")
	vec_velocity.y = Constants.FLY_IMPULSE
	self.set_collision_mask_bit(Constants.MASK_FOREGROUND - 1, false)
	$"player-collision".set_deferred("disabled", true)
	$Hitbox.set_deferred("disabled", true)
		
func _on_TimerImmunity_timeout():
	print("timeout: immunity")
	immunity = false
