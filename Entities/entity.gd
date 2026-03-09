extends Node2D
class_name Entity

@export var display_name:String

var behaviours = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !display_name:
		display_name = name
	
	$display_name_label.text = display_name
	$display_name_label.pivot_offset = -$display_name_label.position

	for node in $Behaviours.get_children():
		if node is Behaviour:
			node.entity = self
			behaviours[node.get_script()]=(node)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$display_name_label.rotation = -rotation
	pass
