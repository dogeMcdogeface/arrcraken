class_name Behaviour_Sail
extends Behaviour

# Sail properties
@export var sail_orientation := Vector2.UP # Local forward direction
@export_range(0.0, 1.0) var sail_orientation_factor := 1.0 # How much wind depends on sail orientation
@export_range(0.0, 1.0) var body_orientation_factor := 0.8 # How much entity resists sideways motion

func process_tick(world_timer:WorldTimer):
	var delta = world_timer.elapsed_days
	var wind = Globals.Wind.getInPos(entity.position)
	
	# Normalize vectors
	var wind_dir = wind.vector.normalized()
	var sail_dir = sail_orientation.normalized()
	var body_dir = Vector2(cos(entity.rotation), sin(entity.rotation)).normalized() # assuming rotation_vector points forward
	
	# Wind push factor based on sail orientation
	var alignment = abs(wind_dir.dot(sail_dir)) # 1 = aligned, 0 = perpendicular
	var push_factor = lerp(1.0, 0.0, sail_orientation_factor * alignment)
	# Now push_factor is 1 if wind perpendicular, 0 if wind fully aligned (depending on wind_importance)
	var wind_push = wind.vector * push_factor * delta
	
	# Entity forward direction
	var forward_component = body_dir * body_dir.dot(wind_push) * body_orientation_factor
	var sideways_component = wind_push - forward_component
	var effective_push = forward_component + sideways_component * (1 - body_orientation_factor)
	
	# Apply movement
	print(wind_push , "	", wind.vector)
	entity.position += effective_push
#	entity.rotation += wind.shear * delta
