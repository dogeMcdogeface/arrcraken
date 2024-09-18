@tool
extends Marker2D

@export var disabled:bool = false:  set = set_disabled

func set_disabled(value: bool):
	disabled = value
	$TextureRect.modulate = Color.BLACK if disabled else Color.WHITE
