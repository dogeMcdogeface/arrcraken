class_name Behaviour_Sail_Rigid
extends Behaviour

@export_range(0, 360, 0.1, "radians_as_degrees") var target_rotation: float = PI

# Sail properties
@export_range(0, 360, 0.1, "radians_as_degrees") var sail_orientation: float = PI
@export_range(0.0, 1.0) var sail_orientation_factor := 1.0
@export_range(0.0, 1.0) var body_orientation_factor := 0.8
@export_range(0.0, 1.0) var shear_factor := 0.8
@export_range(0.0, 1.0) var rotation_resistance_factor := 0.3

# Force tuning
@export var sail_force_scale := 30.0
@export var sideways_drag := 4.0
@export var steering_torque := 10.0

func process_tick(world_timer: WorldTimer):

	var body = entity
	if body == null:
		return

	var wind = Globals.Wind.getInPos(body.position)
	var wind_vec = wind.vector

	# ---------------------------------------------------------
	# RELATIVE WIND (important for physics bodies)
	# ---------------------------------------------------------
	var rel_wind = wind_vec - body.linear_velocity

	var wind_speed = rel_wind.length()
	if wind_speed == 0:
		return

	var wind_dir = rel_wind.normalized()

	# ---------------------------------------------------------
	# BASIC DIRECTIONS
	# ---------------------------------------------------------
	var body_dir = Vector2.from_angle(body.rotation)
	var sail_axis = Vector2.from_angle(body.rotation + sail_orientation)
	var sail_dir = sail_axis.rotated(PI / 2.0)

	auto_trim_sail(wind_vec, world_timer.elapsed_days)

	# ---------------------------------------------------------
	# EFFECT 1: WIND DRAG ON SAIL
	# ---------------------------------------------------------
	var sail_alignment = abs(wind_dir.dot(sail_dir))
	var perpendicular_factor = 1.0 - sail_alignment
	var drag_factor = lerp(1.0, perpendicular_factor, sail_orientation_factor)

	var sail_drag_force = rel_wind * drag_factor

	# ---------------------------------------------------------
	# EFFECT 2: SAIL LIFT
	# ---------------------------------------------------------
	var lift_strength = sail_alignment * (1.0 - sail_alignment)

	var lift_dir = wind_dir.rotated(PI / 2.0)
	if lift_dir.dot(body_dir) < 0:
		lift_dir = -lift_dir

	var sail_lift_force = lift_dir * wind_speed * lift_strength * sail_orientation_factor

	var sail_force = (sail_drag_force + sail_lift_force) * sail_force_scale

	# ---------------------------------------------------------
	# HULL RESISTANCE (keel effect)
	# ---------------------------------------------------------
	var forward_dot = body_dir.dot(sail_force)

	var forward_component = body_dir * max(0.0, forward_dot)
	var sideways_component = sail_force - body_dir * forward_dot

	sideways_component *= (1.0 - body_orientation_factor)

	var effective_push = forward_component + sideways_component

	# Apply force at center
	body.apply_force(effective_push)

	# ---------------------------------------------------------
	# ADDITIONAL SIDEWAYS WATER DRAG
	# ---------------------------------------------------------
	var sideways_vel = body.linear_velocity - body_dir * body.linear_velocity.dot(body_dir)
	body.apply_force(-sideways_vel * sideways_drag)

	# ---------------------------------------------------------
	# STEERING TORQUE
	# ---------------------------------------------------------
	var angle_diff = wrapf(target_rotation - body.rotation, -PI, PI)

	var torque = angle_diff * steering_torque * rotation_resistance_factor
	body.apply_torque(torque)

	# ---------------------------------------------------------
	# WIND SHEAR ROTATION
	# ---------------------------------------------------------
	body.apply_torque(wind.shear * shear_factor)

	# ---------------------------------------------------------
	# VISUAL SAIL
	# ---------------------------------------------------------
	if body.get_node_or_null("%sail"):
		body.get_node("%sail").rotation = sail_orientation


func auto_trim_sail(wind_vec: Vector2, delta: float, trim_speed := 2.0):

	if wind_vec.length() == 0:
		return

	var wind_dir = wind_vec.normalized()
	var body_dir = Vector2.from_angle(entity.rotation)

	var rel_angle = body_dir.angle_to(wind_dir)

	var optimal_angle = rel_angle * 0.5

	var max_sail_angle = PI * 0.45
	optimal_angle = clamp(optimal_angle, -max_sail_angle, max_sail_angle)

	sail_orientation = lerp_angle(
		sail_orientation,
		optimal_angle,
		trim_speed * delta
	)
