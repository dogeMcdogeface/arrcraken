class_name Behaviour_Trader extends Behaviour

@export var price_calculators := InventoryItemList_PriceCalculator.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	Globals.WorldEconomy.register_trader(self)
	pass # Replace with function body.

var lastDate

func process_tick(world_timer:WorldTimer):
	for item in price_calculators.items:
		price_calculators.items[item].calculate_price(entity_storage.inventory.items[item])
	pass


	
