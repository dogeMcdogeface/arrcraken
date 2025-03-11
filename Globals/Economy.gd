extends Node

var last_day = -1
func _process(delta):
	if(Globals.get_days() > last_day):
		last_day = Globals.get_days()
		update_market()
		#print("market update")


################# GLOBAL MARKET #######################################################
var global_market_prices: Inventory = Inventory.new()

func update_market():
	var traders = get_tree().get_nodes_in_group("traders")
	global_market_prices = Inventory.new()
	#get the global average price for each good
	for trader in traders:
		for item in global_market_prices.get_existing_items():
			var trader_price = trader.behaviors[TraderBehavior].prices.get(item) / traders.size()
			var global_price = global_market_prices.get(item)
			global_market_prices.set(item, trader_price +  global_price)
		pass
#######################################################################################
