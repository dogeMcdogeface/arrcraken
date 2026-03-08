class_name Behaviour_Trader extends Behaviour

@export var price_calculators := InventoryItemList_PriceCalculator.new()

var days_of_stock = 5


func _ready() -> void:
	super()
	#for item in price_calculators.items:
	Globals.WorldEconomy.register_trader(self)


func process_tick(world_timer:WorldTimer):
	var producer:Behaviour_Producer = get_behaviour(Behaviour_Producer)
	var consumer:Behaviour_Consumer = get_behaviour(Behaviour_Consumer)
	
	for item in price_calculators.items:
		var price_calculator := price_calculators.items[item]
		price_calculator.stock_normal = entity_storage.size.items[item] /2
		price_calculator.stock_scarcity = entity_storage.size.items[item] /4
		price_calculator.stock_oversupply = entity_storage.size.items[item] /4 * 3

		if consumer:
			price_calculator.stock_scarcity = days_of_stock * consumer.inventory.get_item(item)
		if producer:
			price_calculator.stock_oversupply = entity_storage.size.items[item] - ( days_of_stock * producer.inventory.get_item(item))

		price_calculator.calculate_price(entity_storage.inventory.items[item])
	pass
