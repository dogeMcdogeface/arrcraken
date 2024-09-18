extends CharacterBody2D

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var navigation_targets = get_tree().get_nodes_in_group("navigation_targets")
@onready var next_target = self


@export var linear_accel: float = 50.0
@export var linear_speed: float = 200.0
@export var spinny_accel: float = 5.0 #rad/s
@export var spinny_speed: float = 5.0 #rad/s

#Overwrites the entity's NavigationAgent2D "path_postprocessing" parameter. A less optimized path looks more "organic" 
@export var optimize_path: bool:
	set(value):
		optimize_path = value
		if navigation_agent:
			if optimize_path: 	navigation_agent.path_postprocessing = NavigationPathQueryParameters2D.PATH_POSTPROCESSING_CORRIDORFUNNEL
			else:				navigation_agent.path_postprocessing = NavigationPathQueryParameters2D.PATH_POSTPROCESSING_EDGECENTERED

@export_group("Debug Settings")
#Constantly recalculate path. Probably bad for performance, but makes changes immediately visible
@export var continuous_pathing: bool = false


func _ready():
	modulate =  Debug.get_unique(self).color
	navigation_agent.debug_path_custom_color = Debug.get_unique(self).color
	set_navigation_target(global_position)
	
	optimize_path = optimize_path
	#print(navigation_agent.path_postprocessing)

#func _process(delta):
	#pass

func _physics_process(_delta):
	var delta = _delta * Globals.world_time_scale
	if continuous_pathing:
		set_navigation_target(next_target.global_position)
		
	if ("disabled" in next_target) and (next_target.disabled):
		_on_navigation_agent_2d_navigation_finished()
	elif !navigation_agent.is_navigation_finished():
		steer_towards_target(delta)

	compute_wind_effect()
	compute_velocity(delta)
	
	var collision = move_and_collide(velocity * delta)
	#if collision:
		#print("I collided with ", collision.get_collider().name)
	#move_and_slide()

################# BEHAVIOUR ###########################################################
#Code handling the behaviour of a navigating entity (ships/players/creatures)
#describing high level behaviour such as choosing a destination, running away, trading etc
func _on_navigation_agent_2d_navigation_finished():
	
	if ("disabled" in next_target) and next_target.disabled:
		#Target became unavailable
		#TODO: Reset navigation somehow
		Debug.warn([self, "Target became unavailable ",next_target, navigation_agent.target_position])
		push_warning(self, "Target became unavailable ",next_target, navigation_agent.target_position)
		next_target = navigation_targets.pick_random()
		set_navigation_target(next_target.global_position)
	elif navigation_agent.is_target_reached():
		##do target stuff
		##trade, fight etc
		next_target = navigation_targets.pick_random()
		set_navigation_target(next_target.global_position)
		pass
	elif ! navigation_agent.is_target_reachable():
		#couldn't reach target
		#TODO: Reset navigation somehow
		Debug.warn([self, "Could not reach navigation target",next_target, navigation_agent.target_position])
		push_warning(self, "Could not reach navigation target",next_target, navigation_agent.target_position)
	
#######################################################################################

################# NAVIGATION ##########################################################
#Code handling the navigation entity (ships/players/creatures)
#Mainly dealing with the pathing agent 
func set_navigation_target(movement_target: Vector2):
	call_deferred("_deferred_navigation_target", movement_target)
func _deferred_navigation_target(movement_target: Vector2):
	await get_tree().physics_frame
	navigation_agent.target_position = movement_target
#######################################################################################

################# MANEUVERING #########################################################
#Code handling the steering of the entity (ships/players/creatures)
#Describing low level behaviour such as turning the ship towards the current waypoint, hold position...
func steer_towards_target(delta):
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var target_rotation = global_position.angle_to_point(next_path_position)
	rotation = rotate_toward(rotation, target_rotation, delta * spinny_speed )
	#velocity = global_position.direction_to(next_path_position) * linear_speed
#######################################################################################

################# MOVEMENT ############################################################
#Code handling the movement of a navigating entity (ships/players/creatures)
#Describing wind effects on movement, water resistance etc
var wind = Vector2.ZERO
var force_on_sail = Vector2.ZERO
var dot_to_wind = .0
var reverse_sail = false
var reverse_sail_factor = 0.5

func _on_wind_updated(new_wind: Vector2):
	wind = new_wind
	
func compute_wind_effect():
	dot_to_wind = wind.dot(Vector2.from_angle(rotation))
	if dot_to_wind <= 0.1:
		reverse_sail = true
		force_on_sail = Vector2.from_angle(rotation) * reverse_sail_factor
	else:
		reverse_sail = false
		force_on_sail = wind.project(Vector2.from_angle(rotation))

func compute_velocity(delta):
	var target_velocity = linear_speed * force_on_sail
	velocity = velocity.move_toward(target_velocity, linear_accel* delta)
	navigation_agent.set_velocity(velocity)
#######################################################################################


################# DEBUG ###############################################################
@export var debug :bool = false
var debug_string = "\
velocity:	x: %-10.3f y: %-10.3f dir: %-10.3f mag: %-10.3f 
position:	x: %-10.3f y: %-10.3f rot: %-4.0f %s(%s)
sail cfg:	x: %-10.3f y: %-10.3f dot: %-10.3f rev: %s
"
@onready var debug_args = func(): return [
	velocity.x,
	velocity.y,
	rad_to_deg(velocity.angle()),
	velocity.length(),
	position.x,
	position.y,
	Debug.get_heading_info(rotation).deg,
	Debug.get_heading_info(rotation).arrow ,
	Debug.get_heading_info(rotation).dir,
	force_on_sail.x,
	force_on_sail.y,
	dot_to_wind,
	reverse_sail
	]
#######################################################################################
