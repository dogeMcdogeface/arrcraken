class_name Inventory extends Resource

@export var coin = .0
@export var wood = .0
@export var stone= .0
@export var food= .0
@export var guns= .0


var _existing_items = _get_existing_items()

func _to_string():
	var txt = ""
	var items = _existing_items
	items.sort()
	for item in items:
		txt+= "%s: %04d, "%[item,get(item) ]
	return txt


func _get_existing_items():
	var result = []
	for elem in get_script().get_script_property_list():
		if elem.get("hint_string", "") != get_script().resource_path and !elem.get("name", "").begins_with("_"):
			result.append(elem["name"])
	return result

func get_existing_items():
	return _existing_items
