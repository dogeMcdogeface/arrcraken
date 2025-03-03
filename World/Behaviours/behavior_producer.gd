extends Behavior
class_name ProducerBehavior

@export var rates: Inventory = Inventory.new()


func _process(delta):
	delta = Globals.world_time_scale * delta
	produce(delta)


func produce(delta):
	for item in rates.get_existing_items():
		var amount = owner.inventory.get_item(item)
		amount += rates.get_item(item) * delta / Globals.world_day_duration
		owner.inventory.set_item(item, amount)
