extends Node
class_name WorldEconomy


var update_period := 0.25 #how many days the economy cycle lasts

var item_list:InventoryItemList_float = InventoryItemList_float.new()


var item_list_totals:InventoryItemList_float = InventoryItemList_float.new()
var item_list_average_price:InventoryItemList_float = InventoryItemList_float.new()



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.WorldEconomy = self
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	item_list_totals = InventoryItemList_float.new()
	item_list_average_price = InventoryItemList_float.new()
	for item in item_list.items:
		for trader in traders:
			item_list_totals.items[item] += trader.entity_storage.inventory.items[item]
			item_list_average_price.items[item] += trader.price_calculators.items[item].price / traders.size()
	
	pass


var traders:Array[Behaviour_Trader] = []
func register_trader(behaviour:Behaviour_Trader):
	if(!traders.has(behaviour)):
		traders.append(behaviour)
	
