@tool
class_name WorldMapCity extends WorldMapNavigationTarget

@export var size:int = 0
@export var money:int = 0

@export var inventory: Inventory = Inventory.new()
@export var production: Inventory = Inventory.new()
var prices: Inventory = Inventory.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint(): return
	delta = Globals.world_time_scale * delta
	compute_economy(delta)
	show_debug()


################# ECONOMY #############################################################
func compute_economy(delta):
	produce(delta)
	assert_prices(delta)
	pass

func produce(delta):
	for item in inventory.get_existing_items():
		var amount = inventory.get(item)
		amount += production.get(item) * delta / Globals.world_day_duration
		inventory.set(item, amount)

func assert_prices(delta):
	for item in inventory.get_existing_items():
		var amount = inventory.get(item)
		var price = prices.get(item)
		var target_price = 10 + pow(1.008, 1000 - amount)
		price = lerp(price, target_price, delta / Globals.world_day_duration) 
		prices.set(item, price)
#######################################################################################



################# DEBUG ###############################################################
@export var debug :bool = false
@onready var debug_string = func(): return "\
production:	%s 
inventory:	%s 
prices:		%s" % [
	production,
	inventory,
	prices,
	]

func show_debug():
	#$RichTextLabel.text = label+"\n"+ inventory.to_string()
	$RichTextLabel.text = inventory.to_string()
#######################################################################################
