class_name Behaviour_Trader extends Behaviour

@export var price_calculators := InventoryItemList_PriceCalculator.new()



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lastDate = Globals.WorldTime.world_date
	Globals.WorldEconomy.register_trader(self)
	pass # Replace with function body.

var lastDate

func update():
	var dateDelta = Globals.WorldTime.world_date - lastDate
	if dateDelta < (Globals.WorldTime.world_day_duration * Globals.WorldEconomy.update_period):
		return
	lastDate =  Globals.WorldTime.world_date
	
	for item in price_calculators.items:
		#var deficit = desire.items[item] - entity.inventory.items[item]
		#prices.items[item] = calculate_price(entity.inventory.items[item], desire.items[item])
		price_calculators.items[item].calculate_price(entity.inventory.items[item])
	pass


	
