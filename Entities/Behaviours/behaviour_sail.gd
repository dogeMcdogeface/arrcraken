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

	# ---------------------------------------------------------
	# Basic direction vectors
	# ---------------------------------------------------------
	var wind_vec = wind.vector
	var wind_dir = wind_vec.normalized()
	var wind_speed = wind_vec.length()

	var body_dir = Vector2.from_angle(entity.rotation).normalized() # forward

	# Direction along the sail cloth
	var sail_axis = Vector2.from_angle(entity.rotation + sail_orientation).normalized()

	# Direction the sail is facing (aerodynamic normal)
	var sail_dir = sail_axis.rotated(PI / 2.0)


	auto_trim_sail(wind_vec ,delta)

	# ---------------------------------------------------------
	# EFFECT 1: WIND DRAG ON THE SAIL (perpendicular impact)
	# ---------------------------------------------------------
	# This models the classic "wind pushing the sail like a wall".
	# Maximum force occurs when wind is perpendicular to the sail surface.

	# Dot tells us how aligned wind is with the sail axis
	var sail_alignment = abs(wind_dir.dot(sail_dir)) # 1 = aligned, 0 = perpendicular

	# When aligned, drag should be small. When perpendicular, drag is large.
	var perpendicular_factor = 1.0 - sail_alignment

	# Blend with orientation factor:
	# if sail_orientation_factor = 0 -> sail orientation ignored
	var drag_factor = lerp(1.0, perpendicular_factor, sail_orientation_factor)

	var sail_drag_force = wind_vec * drag_factor


	# ---------------------------------------------------------
	# EFFECT 2: SAIL LIFT (sail acting like a wing)
	# ---------------------------------------------------------
	# When wind hits the sail at an angle, it produces a force
	# perpendicular to the airflow (like an airplane wing).
	# This is what allows sailing somewhat against the wind.

	# Lift strength depends on how oblique the wind is to the sail
	var lift_strength = sail_alignment * (1.0 - sail_alignment)

	# Direction of lift: perpendicular to wind
	var lift_dir = wind_dir.rotated(PI / 2.0)

	# Choose the lift direction that actually pushes the boat forward
	if lift_dir.dot(body_dir) < 0:
		lift_dir = -lift_dir

	var sail_lift_force = lift_dir * wind_speed * lift_strength * sail_orientation_factor


	# ---------------------------------------------------------
	# COMBINE SAIL FORCES
	# ---------------------------------------------------------
	var sail_force = (sail_drag_force + sail_lift_force) * delta


	# ---------------------------------------------------------
	# EFFECT 3: HULL / BODY INTERACTION WITH WATER
	# ---------------------------------------------------------
	# The hull resists sideways motion but allows forward motion.
	# This is essentially keel + water drag behavior.

	var forward_dot = body_dir.dot(sail_force)

	# Forward movement component
	var forward_component = body_dir * max(0.0, forward_dot)

	# Sideways drift component
	var sideways_component = sail_force - body_dir * forward_dot

	# Hull resists sideways motion depending on body_orientation_factor
	sideways_component *= (1.0 - body_orientation_factor)

	var effective_push = forward_component + sideways_component


	# ---------------------------------------------------------
	# APPLY MOVEMENT
	# ---------------------------------------------------------
	entity.position += effective_push


	# ---------------------------------------------------------
	# STEERING TOWARDS TARGET ROTATION
	# ---------------------------------------------------------
	var angle_diff = fposmod((target_rotation - entity.rotation), (2 * PI))
	if angle_diff > PI:
		angle_diff -= 2 * PI

	var target_rotation_step = angle_diff * rotation_resistance_factor * delta
	entity.rotation += target_rotation_step


	# ---------------------------------------------------------
	# WIND SHEAR ROTATION EFFECT (UNCHANGED)
	# ---------------------------------------------------------
	var wind_shear_rotation = wind.shear * shear_factor * delta
	entity.rotation += wind_shear_rotation


	# ---------------------------------------------------------
	# VISUAL SAIL ROTATION
	# ---------------------------------------------------------
	if entity.get_node_or_null("%sail"):
		entity.get_node("%sail").rotation = sail_orientation


func auto_trim_sail(wind_vec: Vector2, delta: float, trim_speed := 2.0):
	if wind_vec.length() == 0:
		return
	
	# Wind direction
	var wind_dir = wind_vec.normalized()
	
	# Ship forward direction
	var body_dir = Vector2.from_angle(entity.rotation)
	
	# Wind relative to ship
	var rel_angle = body_dir.angle_to(wind_dir)
	
	# Ideal sail angle (roughly perpendicular to wind)
	var optimal_angle = rel_angle * 0.5
	
	# Clamp so sail never flips behind the mast
	var max_sail_angle = PI * 0.45
	optimal_angle = clamp(optimal_angle, -max_sail_angle, max_sail_angle)
	
	# Smoothly rotate sail toward optimal angle
	sail_orientation = lerp_angle(
		sail_orientation,
		optimal_angle,
		trim_speed * delta
	)
