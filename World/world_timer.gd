class_name WorldTimer

var last_time_ms: float = 0.0
var interval_ms: float = 0.0
var elapsed_ms: float = 0.0


var last_time_days: float:
	get: return last_time_ms / Globals.WorldTime.world_day_duration
	set(value): last_time_ms = value * Globals.WorldTime.world_day_duration


var interval_days: float:
	get: return interval_ms / Globals.WorldTime.world_day_duration
	set(value): interval_ms = value * Globals.WorldTime.world_day_duration


var elapsed_days: float:
	get: return elapsed_ms / Globals.WorldTime.world_day_duration


func _init(_interval_days:float):
	interval_days = _interval_days
func _ready():
	last_time_ms = Globals.WorldTime.world_date


func tick(is_paused:= false) -> bool:
	var now := Globals.WorldTime.world_date
	var delta := now - last_time_ms
	
	if is_paused:
		last_time_ms = now - elapsed_ms
		return false
	
	elapsed_ms = delta
	
	if delta < interval_ms:
		return false
	
	last_time_ms = now
	return true
