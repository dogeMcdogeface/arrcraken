extends Resource
class_name Inventory


# This is cancer. Please ignore this
const items_start_token = "items_start_token"
const items_end_token = "items_end_token"
@export_subgroup(items_start_token, items_start_token)
@export var wood = 0.
@export var stone = 0.
@export var garlic = 0. 
@export var gold = 0.
# Add new items here
# ...
@export_subgroup(items_end_token, items_end_token)


var existing_items = extract_items()
var item_to_resource = link_items_to_resources()

func _init(): pass


func extract_items():
	var properties = get_script().get_script_property_list()
	var extracted_names = []

	var collecting = false
	for property in properties:
		if property["name"] == items_start_token:
			collecting = true
			continue  # Skip the start token itself
		if property["name"] == items_end_token:
			break  # Stop collecting when we reach the end token
		if collecting:
			extracted_names.append(property["name"])
	return extracted_names

func link_items_to_resources():
	var dict = {}
	for key in get_existing_items():
		dict[key] = load("res://Items/item_"+ key +".tres")
	return dict

func get_item(item) -> float:
	return get(item)  # Return the amount, default to 0 if item doesn't exist

func set_item(item, amount:float) -> void:
	set(item,  amount)  # Update existing item amount

func get_existing_items():
	return existing_items


# Helper function to format inventory for better readability
func to_debug_string() -> String:
	var output = ""
	for key in get_existing_items():
		output += "%s: %6.1f\t" % [key, get_item(key)]
	return output
