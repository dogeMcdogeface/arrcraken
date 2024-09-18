extends Camera2D

@export var locked:bool = false
@export var zoom_follows_mouse:bool = true
@export var min_zoom: float = 0.08
@export var max_zoom: float = 2
@export var zoom_increment: float = 1.2


################# INPUT HANDLING ######################################################
# Handle input events such as zooming and dragging.
func _input(event: InputEvent) -> void:
	if locked:
		return
	# Zoom custom inputs.
	if Input.is_action_pressed("map_zoom_in"):
		_zoom(+1)
	elif Input.is_action_pressed("map_zoom_out"):
		_zoom(-1)
	
	# Drag custom input.
	if Input.is_action_pressed("map_drag") and event is InputEventMouseMotion:
		_drag(event.relative)
#######################################################################################


################# MOVEMENT ############################################################
# Handles dragging of the camera based on mouse motion, adjusting the position.
func _drag(relative_motion: Vector2) -> void:
	position -= relative_motion / zoom


# Handles zooming in and out based on user input.
# Adjusts the camera's zoom factor and repositions based on the current mouse position.
func _zoom(relative_motion: float) -> void:
	var curr_mouse_position = get_local_mouse_position()
	if relative_motion > 0:
		zoom *= zoom_increment
	else:
		zoom /= zoom_increment
	zoom = zoom.clampf(min_zoom, max_zoom)
	# Adjust the position based on the change in zoom level.
	if zoom_follows_mouse:
		position += curr_mouse_position - get_local_mouse_position()
		reset_smoothing()
#######################################################################################
