extends Node2D
class_name Entity

@export var display_name:String

var behaviours = {}
#@export var inventory:InventoryItemList_float = InventoryItemList_float.new()
#@export var inventory_size:InventoryItemList_float = InventoryItemList_float.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#inventory = inventory.duplicate(true) #Even when making the inventory resource unique, duplicating an entity still causes the twins to share the same inventory...
	if !display_name:
		display_name = name
		
	for node in $Behaviours.get_children():
		if node is Behaviour:
			node.entity = self
			behaviours[node.get_script()]=(node)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$display_name_label.text = display_name
	for behaviour in behaviours:
		behaviours[behaviour].update()
	pass
