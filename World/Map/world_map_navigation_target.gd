@tool
extends Marker2D


@export var disabled:bool = false:  set = set_disabled

func set_disabled(value: bool):
	disabled = value
	if disabled:
		$TextureRect.modulate = Color.BLACK
	else:
		$TextureRect.modulate = Color.WHITE


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
