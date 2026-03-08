class_name Behaviour_Consumer extends Behaviour

@export var inventory := InventoryItemList_float.new()


func process_tick(world_timer:WorldTimer):
	for item in entity_storage.inventory.items:
		var consumed = inventory.items[item] * world_timer.elapsed_days
		entity_storage.remove(item, consumed)
