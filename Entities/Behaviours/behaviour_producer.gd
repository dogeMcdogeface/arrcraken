class_name Behaviour_Producer extends Behaviour

@export var inventory := InventoryItemList_float.new()


func process_tick(world_timer:WorldTimer):
	for item in entity_storage.inventory.items:
		var produced = inventory.items[item] * world_timer.elapsed_days
		var result = entity_storage.deposit(item, produced, Behaviour_Storage.OverflowMode.DEPOSIT_ALL_IF_CLEAR)
