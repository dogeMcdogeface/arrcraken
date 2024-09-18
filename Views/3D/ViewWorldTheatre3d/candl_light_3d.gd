extends OmniLight3D

@export var flicker_speed = 100.
@export var shake_speed = 100.
@export var shake:bool = false
@onready var original_position = position
# Called when the node enters the scene tree for the first time.
var rng = RandomNumberGenerator.new()
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#light_projector.noise.offset.x += delta * flicker_speed
	var v = light_energy + (rng.randf_range(-0.5, 0.5)*delta * flicker_speed)
	var p = original_position + (Vector3.ONE * rng.randf_range(-0.01,0.01) * delta * shake_speed)
	light_energy = clamp(v, 0.5, 2)
	if shake:
		position = p
	pass
