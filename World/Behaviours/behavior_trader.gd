extends Behavior
class_name TraderBehavior


@export var desires: Inventory = Inventory.new()
var prices: Inventory = Inventory.new()

@export var TradeDelay : float = 1
var TradeDelayElapsed = 0


func _ready():
	owner.add_to_group(Globals.TRADEGROUP)


func _process(delta):
	delta = Globals.world_time_scale * delta
	adjust_prices(delta)
	TradeDelayElapsed += delta
	if(TradeDelayElapsed > TradeDelay * Globals.world_day_duration):
		TradeDelayElapsed = 0
		background_trade()
	
func background_trade():
	var tradePartner = owner.get_tree().get_nodes_in_group(Globals.TRADEGROUP).pick_random()
	if tradePartner == owner: return
	propose_trade(tradePartner)

func propose_trade(tradePartner) -> bool:
	var comparason = compare_economies(tradePartner)
	#print("comp: ",comparason)
	
	if comparason.smallest_key == comparason.largest_key: return false
	#print("not trading the same item")
	
	# Self wants to get it's highest valued item (which the partner wants less),
	# while offering the lowest value item that the partner wants most
	var demand = {
		item =  comparason.largest_key,
		price = tradePartner.behaviors[TraderBehavior].prices.get_item(comparason.largest_key),
		amount = 1,
	}
	var offer = {
		item =  comparason.smallest_key,
		price = prices.get_item(comparason.smallest_key),
		amount = (demand.price * demand.amount) / prices.get_item(comparason.smallest_key),
	}
	
	
	#print("offer:" , offer, demand)
	
	if owner.inventory.get_item(offer.item) < offer.amount: return false
	if tradePartner.inventory.get_item(demand.item) < demand.amount: return false
	#print("partners have enough material")

	
	
	if !evaluate_trade(demand, offer): return false
	#print("offer accepted 1")
	if !tradePartner.behaviors[TraderBehavior].evaluate_trade(offer, demand): return false #invert order for partner!
	#print("offer accepted 2")
	execute_trade(demand, offer, tradePartner)
	
	return false


func execute_trade(demand, offer, tradePartner):
	owner.inventory.set(demand.item, owner.inventory.get(demand.item) + demand.amount)
	tradePartner.inventory.set(demand.item, tradePartner.inventory.get(demand.item) - demand.amount)
	
	owner.inventory.set(offer.item, owner.inventory.get(offer.item) - offer.amount)
	tradePartner.inventory.set(offer.item, tradePartner.inventory.get(offer.item) + offer.amount)
	
	#print("Executing trade", owner, tradePartner)  
	print("Trading ", self.owner.name, "->",tradePartner.name ," ", demand, offer)  



func evaluate_trade(demand, offer) -> bool:
	if (offer.price * offer.amount) <= (demand.price * demand.amount):
		return true
	else:
		return false


func compare_economies(trade_partner):
	var ledger = {}
	var smallest_key = null
	var largest_key = null
	var smallest_value = null
	var largest_value = null

	for key in prices.get_existing_items():
		var value = prices.get(key) - trade_partner.behaviors[TraderBehavior].prices.get(key)
		
		if value == 0: continue
		if value < 0 and owner.inventory.get_item(key)<=0 :continue
		if value > 0 and trade_partner.inventory.get_item(key)<=0 :continue

		ledger[key] = value

		if smallest_value == null or value < smallest_value:
			smallest_value = value
			smallest_key = key

		if largest_value == null or value > largest_value:
			largest_value = value
			largest_key = key

	return {
		"ledger": ledger,
		"smallest_key": smallest_key,
		"smallest_value": smallest_value,
		"largest_key": largest_key,
		"largest_value": largest_value
	}



func adjust_prices(delta):
	for item in prices.get_existing_items():
		var amount = owner.inventory.get_item(item)
		var price = prices.get_item(item)
		var desire = desires.get_item(item)
		var target_price = 10 + pow(1.002, desire - amount)
		prices.set_item(item, target_price)
