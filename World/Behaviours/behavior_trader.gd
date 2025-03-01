extends Behavior
class_name TraderBehavior

@export var prices: Inventory = Inventory.new()
@export var desire: Inventory = Inventory.new()

func _setup_local_to_scene():
	owner.add_to_group("traders")


func _process(delta):
	adjust_prices(delta)


func adjust_prices(delta):
	for item in prices.get_existing_items():
		var amount = owner.inventory.get_item(item)
		var price = prices.get_item(item)
		var desire = desire.get_item(item)
		var target_price = 10 + pow(1.008, desire - amount)
		prices.set_item(item, target_price)
