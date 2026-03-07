extends Resource
class_name PriceCalculator


@export_group("Price Ranges")
@export var price_scarcity := 500.0
@export var price_normal := 200.0
@export var price_oversupply := 50.0
@export var price_saturation := 10.0

@export_group("Stock Ranges")
@export var stock_scarcity := 20.0
@export var stock_normal := 60.0
@export var stock_oversupply := 100.0


@export_group("Factors")
@export var k_scarcity := 2.0
@export var k_normal := 1.0
@export var k_oversupply := 1.5

@export_group("Stability")
@export var global_market_influence := 0.1
var item

#temporary values
var stock:float
var price:float
var stock_target:= [0.0, ""]
var price_history = []


func _init(_item=null):
	item = _item

func calculate_price(m: float, dry_run:bool = false) -> float:
	var tmp_price
	var tmp_stock_target
	
	#m = clamp(m, 0.0, stock_oversupply)

	if m < stock_scarcity:
		tmp_stock_target = [stock_scarcity, "scarcity"]
		tmp_price = price_normal + (price_scarcity - price_normal) * pow((stock_scarcity - m) / stock_scarcity, k_scarcity)
	elif m < stock_normal:
		tmp_stock_target = [stock_normal, "normal"]
		tmp_price = price_oversupply + (price_normal - price_oversupply) * pow((stock_normal - m) / (stock_normal - stock_scarcity), k_normal)
	elif m < stock_oversupply:
		tmp_stock_target = [stock_oversupply, "oversupply"]
		tmp_price =  price_saturation + (price_oversupply - price_saturation) * pow((stock_oversupply - m) / (stock_oversupply - stock_normal), k_oversupply)
	else:
		tmp_stock_target = [stock_oversupply, "saturation"]
		tmp_price = price_saturation
	
	if(item and Globals.WorldEconomy.item_list_average_price.items[item]):
		tmp_price = (1-global_market_influence) * tmp_price + (global_market_influence) * Globals.WorldEconomy.item_list_average_price.items[item]
	
	tmp_price = clamp(tmp_price, price_saturation, price_scarcity)
	
	if dry_run:
		return tmp_price
	
	stock = clamp(m, 0.0, stock_oversupply)
	price = clamp(tmp_price, price_saturation, price_scarcity)
	stock_target = tmp_stock_target
	price_history.append(price)
	if price_history.size() > 50:
		price_history.pop_front()
	return price
