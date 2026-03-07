extends Resource
class_name PriceCalculator


@export_group("Price Ranges")
@export var price_scarcity := 500.0
@export var price_normal := 200.0
@export var price_oversupply := 10.0

@export_group("Stock Ranges")
@export var stock_scarcity := 20.0
@export var stock_normal := 60.0
@export var stock_oversupply := 100.0


@export_group("Factors")
@export var k_scarcity := 2.0
@export var k_normal := 1.0
@export var k_oversupply := 1.5

#temporary values
var stock:float
var price:float
var stock_target:= [0, ""]

func calculate_price(m: float) -> float:
	stock = m
	m = clamp(m, 0.0, stock_oversupply)

	if m < stock_scarcity:
		stock_target = [stock_scarcity, "scarcity"]
		price = price_normal + (price_scarcity - price_normal) * pow((stock_scarcity - m) / stock_scarcity, k_scarcity)
	elif m < stock_normal:
		stock_target = [stock_normal, "normal"]
		price = price_oversupply + (price_normal - price_oversupply) * pow((stock_normal - m) / (stock_normal - stock_scarcity), k_normal)
	else:
		stock_target = [stock_oversupply, "oversupply"]
		price = price_oversupply * pow((stock_oversupply - m) / (stock_oversupply - stock_normal), k_oversupply)

	return price
