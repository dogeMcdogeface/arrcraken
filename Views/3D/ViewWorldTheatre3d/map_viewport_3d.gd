extends MeshInstance3D

@export var locked:bool = false
@export var zoom_follows_mouse:bool = true
@export var min_zoom: float = 0.5
@export var max_zoom: float = 0.92
@export var zoom_increment: float = 1.2


################# INPUT HANDLING ######################################################
# Handle input events such as zooming and dragging.
func _unhandled_input(event: InputEvent) -> void:
	if locked:
		return
	# Zoom custom inputs.
	if event.is_action_pressed("map_zoom_in"):
		_zoom(+1)
	elif event.is_action_pressed("map_zoom_out"):
		_zoom(-1)
	
	# Drag custom input.
	if Input.is_action_pressed("map_drag") and event is InputEventMouseMotion:
		_drag(event.relative)
#######################################################################################


################# MOVEMENT ############################################################
# Handles dragging of the camera based on mouse motion, adjusting the position.
func _drag(relative_motion: Vector2) -> void:
	position.x += relative_motion.x /1000#/ zoom
	position.z += relative_motion.y /1000#/ zoom


# Handles zooming in and out based on user input.
# Adjusts the camera's zoom factor and repositions based on the current mouse position.
func _zoom(relative_motion: float) -> void:
	if relative_motion > 0:
		position.y *= zoom_increment
	else:
		position.y /= zoom_increment
	position.y = clamp(position.y, min_zoom, max_zoom)
	pass
#######################################################################################
