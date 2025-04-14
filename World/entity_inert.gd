extends Area2D


#func _process(delta: float) -> void:

	
func _physics_process(delta: float) -> void:
	delta *= Globals.WorldTime.scale
	var wind = Globals.Wind.getInPos(position)
	position += wind * delta
