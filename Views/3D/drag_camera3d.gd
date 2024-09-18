extends Node3D


@onready var gimball_1 = $gimball_1
@onready var gimball_2 = $gimball_1/gimball_2
@onready var camera    = $gimball_1/gimball_2/Camera3D


@onready var target_azimuth   = gimball_1.rotation.y
@onready var target_elevation = gimball_2.rotation.x
@onready var target_zoom      = camera.transform.origin.y
@export  var speed_azimuth    = 8.0
@export  var speed_elevation  = 1.0
@export  var speed_zoom       = 1.0
@export  var limit_elevation  = Vector2(0.,80.)
@export  var limit_zoom       = Vector2(2.,20.)


@export var debug :bool = false
var debug_string = "
Camera Target:  azi: %-7.3f  rot: %-7.3f  zoom: %-7.3f
Camera Current: azi: %-7.3f  rot: %-7.3f  zoom: %-7.3f"
@onready var debug_args = func(): return [
	target_azimuth,
	target_elevation,
	target_zoom,
	gimball_1.rotation.y,
	gimball_2.rotation.x,
	camera.transform.origin.y
]




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	gimball_1.rotation.y = interpolate(gimball_1.rotation.y, target_azimuth,   5, delta)
	gimball_2.rotation.x = interpolate(gimball_2.rotation.x, target_elevation, 5, delta)
	camera.transform.origin.y = interpolate(camera.transform.origin.y, target_zoom, 3, delta)
	pass

func interpolate (a, b, speed, delta):
	return a + (b - a) * speed * delta

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_RIGHT:
			var target_y = (-event.relative.x / get_viewport().get_visible_rect().size.x) * speed_azimuth
			var target_x = (-event.relative.y / get_viewport().get_visible_rect().size.y) * speed_elevation
			target_azimuth   += (target_y)
			target_elevation += (target_x)
			target_elevation = clamp(target_elevation, deg_to_rad( limit_elevation.x), deg_to_rad( limit_elevation.y))
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE )
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom -= 1.
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom += 1.
		target_zoom = clamp(target_zoom, ( limit_zoom.x), ( limit_zoom.y))
		
