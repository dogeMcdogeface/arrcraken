class_name Behaviour_Sail
extends Behaviour


@export_range(0, 360, 0.1, "radians_as_degrees") var target_rotation: float = PI  # Degrees, clockwise from right


# Sail properties
@export_range(0, 360, 0.1, "radians_as_degrees") var sail_orientation: float = PI  # Degrees, clockwise from right
@export_range(0.0, 1.0) var sail_orientation_factor := 1.0 # How much wind depends on sail orientation
@export_range(0.0, 1.0) var body_orientation_factor := 0.8 # How much entity resists sideways motion
@export_range(0.0, 1.0) var shear_factor := 0.8 # How much entity is affected by shear 
@export_range(0.0, 1.0) var rotation_resistance_factor := 0.3 # How much entity opposes rotation

func process_tick(world_timer:WorldTimer):
	var delta = world_timer.elapsed_days
	var wind = Globals.Wind.getInPos(entity.position)
	
	# Normalize vectors
	var wind_dir = wind.vector.normalized()
	var body_dir = Vector2.from_angle(entity.rotation).normalized() # assuming rotation_vector points forward
	var sail_dir = Vector2.from_angle(entity.rotation + sail_orientation).normalized()
	
	# Wind push factor based on sail orientation
	var alignment = abs(wind_dir.dot(sail_dir)) # 1 = aligned, 0 = perpendicular
	var push_factor = lerp(1.0, 0.0, sail_orientation_factor * alignment)
	# Now push_factor is 1 if wind perpendicular, 0 if wind fully aligned (depending on wind_importance)
	var wind_push = wind.vector * push_factor * delta
	
	# Entity forward direction
	# Projection of wind onto the ship forward axis
	var forward_dot = body_dir.dot(wind_push)

	# Forward thrust from tailwind only
	var forward_component = body_dir * max(0.0, forward_dot) * body_orientation_factor

	# Pure sideways drift
	var sideways_component = wind_push - body_dir * forward_dot

	# If wind was pushing backwards, convert some of it into weak forward thrust
	if forward_dot < 0.0:
		var converted = -forward_dot 
		sideways_component += body_dir * converted

	# Apply sideways resistance
	var effective_push = forward_component + sideways_component * (1.0 - body_orientation_factor)
	
	# Apply movement
	entity.position += effective_push
	#entity.rotation += wind.shear * delta
	
	# Steering towards the target rotation
	var angle_diff = fposmod((target_rotation - entity.rotation), (2 * PI))
	if angle_diff > PI:
		angle_diff -= 2 * PI  # Make the angle difference fall within [-PI, PI]

	# Apply a smoothing factor for rotation
	var target_rotation_step = angle_diff * rotation_resistance_factor * delta
	entity.rotation += target_rotation_step

	# Wind shear effect on rotation (consider how much the wind affects rotation)
	var wind_shear_rotation = wind.shear * shear_factor * delta 
	entity.rotation += wind_shear_rotation
