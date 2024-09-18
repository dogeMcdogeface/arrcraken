extends Node

var speed = Vector2.ZERO
var position = Vector2.ZERO
var rotation = Vector2.UP

var wind = Vector2.ZERO
var towind   = 0.

## movement_types documentation
enum movement_types {
	## BY_WIND: Player input is used to rotate the ship and set sail mode. Player speed is then computed by applying wind to current ship configuration
	BY_WIND,
	## WASD_TO_XY: Player input is used to change X (w+s) and Y (a+d) position 
	WASD_TO_XY,
	## WASD_TO_SPEED: Player input is used to set ship speed.
	WASD_TO_SPEED,
	}

## Player movement mode
## [br][br]
## [b]BY_WIND[/b]: Player input is used to rotate the ship and set sail mode. Player speed is then computed by applying wind to current ship configuration
## [br][br]
## [b]WASD_TO_XY[/b]: Player input is used to change X (w+s) and Y (a+d) position 
## [br][br]
## [b]WASD_TO_SPEED[/b]: Player input is used to set ship speed.
@export var movement_type: movement_types = movement_types.BY_WIND

@export var debug :bool = false
var debug_string = "
speed:	 	x: %-10.3f y: %-10.3f dir: %-10.3f mag: %-10.3f 
position:	x: %-10.3f y: %-10.3f rot: %-3.0f %s
sail cfg:	w: %-10.3f
"
@onready var debug_args = func(): return [
	speed.x,
	speed.y,
	rad_to_deg(speed.angle()),
	speed.length(),
	position.x,
	position.y,
	Debug.get_heading_info(rotation).deg,
	Debug.get_heading_info(rotation).dir,
	towind,
	]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	calculate_position(delta)
	notify_position()


func calculate_position(delta):
	var player_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	match movement_type:
		movement_types.BY_WIND:
			calculate_wind_effect(delta)
		movement_types.WASD_TO_XY:
			speed = Vector2.ZERO
			position += player_input * delta
		movement_types.WASD_TO_SPEED:
			speed += player_input * delta
			position += speed * delta
		var value:
			print("Unknown movement type ", value)

func calculate_wind_effect(delta):
	var steering = Input.get_axis("move_left", "move_right")
	rotation = rotation.rotated (steering * delta)
	
	speed = wind.project(rotation)
	position += speed * delta
	pass


func notify_position():
	for member in get_tree().get_nodes_in_group("player_position_listeners"):
		member.player_position_updated(position, rotation)

func wind_updated( new_wind: Vector2 ):
		wind = new_wind
		
