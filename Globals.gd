extends Node

var base_physics_ticks_per_second = ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
var max_physics_steps_per_frame = ProjectSettings.get_setting("physics/common/max_physics_steps_per_frame")


@export var min_world_time_scale: float = 0.2
@export var max_world_time_scale: float = 1000
@export_range(0.2, 1000)  var _world_time_scale: float = 1:
	set(value):
		value = clamp(value, min_world_time_scale, max_world_time_scale)
		_world_time_scale = value
		world_time_scale = value
		Engine.physics_ticks_per_second = max(base_physics_ticks_per_second, base_physics_ticks_per_second * value/2)
		Engine.max_physics_steps_per_frame = max(max_physics_steps_per_frame, max_physics_steps_per_frame * value)
const WorldMapProperties = {
	"size": Vector2(10000,10000)
}

static var world_time_scale: float = 1
