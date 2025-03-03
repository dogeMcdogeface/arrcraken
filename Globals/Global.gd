extends Node

################# GROUPS ##############################################################
const TRADEGROUP = "traders"
#######################################################################################

################# MAP #################################################################

var WorldMapProperties = {
	"size": Vector2(10000,10000)
}
#######################################################################################


################# SIMULATION SPEED ####################################################
var base_physics_ticks_per_second = ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
var max_physics_steps_per_frame = ProjectSettings.get_setting("physics/common/max_physics_steps_per_frame")

var world_time_scale: float = 1:
	set(value):
		world_time_scale = value
		Engine.physics_ticks_per_second = max(base_physics_ticks_per_second, base_physics_ticks_per_second * value/2)
		Engine.max_physics_steps_per_frame = max(max_physics_steps_per_frame, max_physics_steps_per_frame * value)
#######################################################################################


################# CALENDAR ############################################################
var world_date:float = 0
var world_day_duration: float = 10. #seconds

func get_days():
	return int(world_date / world_day_duration)
func get_date():
	var sub_day = fmod(world_date, world_day_duration)  / world_day_duration
	var t = int(world_date / world_day_duration)
	return {
		p =  Debug.duration_visual_v[round(sub_day * (Debug.duration_visual_v.size() - 1))],
		sub_day = sub_day,
		day = int(t) % 30,
		month = int(t) / 30 % 12,
		year = int(t)  / 30 / 12
	}
func get_date_string():
	return " {p} {day}/{month}/{year}".format(get_date())
#######################################################################################


func _process(delta):
	world_date += world_time_scale * delta
	
