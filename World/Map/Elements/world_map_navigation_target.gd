@tool
class_name WorldMapNavigationTarget extends Marker2D

@export var disabled:bool = false:  set = set_disabled

@export var label:String = get_name():
	set(value):
		label = value
		if label == null or label == "":
			label = get_name()

func set_disabled(value: bool):
	disabled = value
	modulate = Color.BLACK if disabled else Color.WHITE
