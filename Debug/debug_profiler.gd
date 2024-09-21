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
var debug_string = func(): return "\
time_scale:       %6.3f 			| world_time_scale: %6.3f
fps:              %4.0f				| max_physics_steps_per_frame: %-10.0f
max_fps:          %4.0f				| physics_ticks_per_second:    %-2.0f
frame_time  (ms): %6.3f (%-5.0f)	| process_time      (ms): %6.3f (%-4.0f)	
physics_time(ms): %6.3f (%-5.0f)	| physics_frame_time(ms): %6.3f (%-4.0f)" % [
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

#https://docs.godotengine.org/en/stable/tutorials/scripting/debug/the_profiler.html
#The main measurements are frame time, physics frame, idle time, and physics time.
	#-The frame time is the time it takes Godot to execute all the logic for an entire image,
	# from physics to rendering.
	#-Physics frame is the time Godot has allocated between physics updates.
	# In an ideal scenario, the frame time is whatever you chose: 16.66 milliseconds by default, 
	# which corresponds to 60FPS. It's a frame of reference you can use for everything else around it.
	#-Idle time is the time Godot took to update logic other than physics, such as code that lives 
	# in _process or timers and cameras set to update on Idle.
	#-Physics time is the time Godot took to update physics tasks, like _physics_process and
	# built-in nodes set to Physics update.
		#Note
	#Frame Time includes rendering time. Say you find a mysterious spike of lag in your game,
	#but your physics and scripts are all running fast. The delay could be due to the appearance
	#of particles or visual effects!
