xtends Resource
class_name Inventory

@export var items = {
	preload("res://Items/item_wood.tres"):0,
	preload("res://Items/item_garlic.tres"):0,
	preload("res://Items/item_stone.tres"):0,
	}


# Helper function to format inventory for better readability
func to_debug_string() -> String:
	var output = ""
	for key in items.keys():
		output += "%s: %4d\t" % [key.name, items[key]]
	return output
