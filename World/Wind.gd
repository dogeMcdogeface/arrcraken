extends Node

@export var direction = Vector2.DOWN
@export var paused = false
@export var max_speed = 50
@export var variance_r = 0.05
@export var variance_m = 0.05
var rng = RandomNumberGenerator.new()


@export var debug :bool = false
@onready var debug_string = func(): return "\
speed:	 	x: %-10.3f y: %-10.3f dir: %-3.0f %s %s mag: %-10.3f " % [
	direction.x,
	direction.y,
	Debug.get_heading_info(direction).deg,
	Debug.get_heading_info(direction).arrow,
	Debug.get_heading_info(direction).dir,
	direction.length(),
	]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !paused:
		var curr_magnitude = direction.length()
		var next_magnitude = curr_magnitude + rng.randf_range(-variance_m, variance_m)
		next_magnitude = clampf(next_magnitude, 0.1, 1)
		direction = direction.normalized() * next_magnitude
		
		var next_rotation =  rng.randf_range(-variance_r, variance_r)
		direction = direction.rotated(next_rotation)
		#direction = direction.abs() * direction.normalized() * delta
	for member in get_tree().get_nodes_in_group("wind_listeners"):
		#print(get_path_to(member))
		member._on_wind_updated(direction);
	pass
