extends Node
class_name WorldTime

@export_category("TimeScale")
@export var min_world_time_scale: float = 0.0
@export var max_world_time_scale: float = 100
@export_range(0.0, 100)  var _world_time_scale: float = 1:
	set(value):
		value = clamp(value, min_world_time_scale, max_world_time_scale)
		_world_time_scale = value
		scale = value



################# SIMULATION SPEED ####################################################
var base_physics_ticks_per_second = ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
var max_physics_steps_per_frame = ProjectSettings.get_setting("physics/common/max_physics_steps_per_frame")

var scale: float = 1:
	set(value):
		scale = value
		Engine.physics_ticks_per_second = max(base_physics_ticks_per_second, base_physics_ticks_per_second * value/2)
		Engine.max_physics_steps_per_frame = max(max_physics_steps_per_frame, max_physics_steps_per_frame * value)
#######################################################################################


################# CALENDAR ############################################################
@export_category("Date")
@export var world_day_duration: float = 10. #seconds
var world_date:float = 0

const duration_visual_v = ["█", "▇", "▆", "▅", "▄", "▃", "▂", "▁", "▔"]
const duration_visual_h = ["█", "▉", "▊", "▋", "▌", "▍", "▎", "▏", " "]

func get_days():
	return int(world_date / world_day_duration)
func get_date():
	var sub_day = fmod(world_date, world_day_duration)  / world_day_duration
	var t = int(world_date / world_day_duration)
	return {
		p =  duration_visual_v[round(sub_day * (duration_visual_v.size() - 1))],
		sub_day = sub_day,
		day = int(t) % 30,
		month = int(t) / 30 % 12,
		year = int(t)  / 30 / 12
	}
func get_date_string():
	return " {p} {day}/{month}/{year}".format(get_date())
#######################################################################################

func _ready() -> void:
	Globals.WorldTime = self

func _process(delta):
	world_date += scale * delta
	#print(Globals.WorldTime)
