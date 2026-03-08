class_name Behaviour_Producer extends Behaviour

@export_range(0.0, 365.0, 0.1, "suffix:days")
var production_interval:float = 0.5 #how many days the production cycle lasts

@export var inventory := InventoryItemList_float.new()




func process_tick(world_timer:WorldTimer):
	for item in entity_storage.inventory.items:
		var produced = inventory.items[item] * world_timer.elapsed_days
		entity_storage.inventory.items[item] += produced
			
