extends Node

@export var resolution:int = 20
@export var x_scroll = 0.01
@export var y_scroll = 0.01
@export var z_scroll = 0.01
var x = 0
var y = 0
var z = 0



var targetXY = Vector2(0,0)

func _ready() -> void:
	$WindNoise.texture.height = resolution
	$WindNoise.texture.width = resolution
	$WindIllustrator.material.set_shader_parameter("texture_size", Vector2(resolution,resolution))


func _process(delta: float) -> void:
	x += x_scroll * delta 
	y += y_scroll * delta 
	z += z_scroll * delta 
	
	$WindNoise.texture.noise.offset.x = (x)
	$WindNoise.texture.noise.offset.y = (y)
	$WindNoise.texture.noise.offset.z = (z)
	print($WindNoise.texture.noise.offset)
