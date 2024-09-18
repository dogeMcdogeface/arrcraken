extends FogVolume

@export var speed = 10.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	material.density_texture.noise.offset.z += speed *delta
