class_name Behaviour_Consumer extends Behaviour

@export_range(0.0, 365.0, 0.1, "suffix:days")
var consumption_interval:float = 2 #how many days the consumption cycle lasts

@export var inventory := InventoryItemList_float.new()


func process_tick(world_timer:WorldTimer):
		for item in entity_storage.inventory.items:
			var consumed = inventory.items[item] * world_timer.elapsed_days
			entity_storage.inventory.items[item] -= consumed
