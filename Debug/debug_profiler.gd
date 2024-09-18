extends EngineProfiler
class_name  DebugProfiler

var frame_time: float
var process_time: float
var physics_time: float
var physics_frame_time: float

func _tick(_frame_time: float, _process_time: float, _physics_time: float, _physics_frame_time: float):
	frame_time = _frame_time
	process_time = _process_time
	physics_time = _physics_time
	physics_frame_time = _physics_frame_time


func get_name():
	return get_class()

var debug :bool = true
var debug_string = "\
time_scale:       %6.3f 			| world_time_scale: %6.3f
fps:              %4.0f				| max_physics_steps_per_frame: %-10.0f
max_fps:          %4.0f				| physics_ticks_per_second:    %-2.0f
frame_time  (ms): %6.3f (%-5.0f)	| process_time      (ms): %6.3f (%-4.0f)	
physics_time(ms): %6.3f (%-5.0f)	| physics_frame_time(ms): %6.3f (%-4.0f)"
var debug_args = func(): return [
	Engine.time_scale,
	Globals.world_time_scale,
	Engine.get_frames_per_second(),
	Engine.max_physics_steps_per_frame,
	Engine.max_fps,
	Engine.physics_ticks_per_second,
	frame_time * 1000, 1 / frame_time,
	process_time* 1000,1 / process_time,
	physics_time* 1000,1 / physics_time,
	physics_frame_time* 1000,1 / physics_frame_time,
]
