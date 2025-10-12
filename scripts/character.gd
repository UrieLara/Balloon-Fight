extends KinematicBody2D
onready var animations = $Animations

var vector_velocity = Vector2.ZERO

func apply_gravity(delta):
	vector_velocity.y = Constants.GRAVITY * delta
	if is_on_floor():
		vector_velocity.y = 0
		
	return vector_velocity.y
		
func teletransport():
	if global_position.x < 0 - Constants.SIZE_X:
		global_position.x = Constants.MAX_WINDOW_X
	elif global_position.x > Constants.MAX_WINDOW_X + Constants.SIZE_X:
		global_position.x = 0

