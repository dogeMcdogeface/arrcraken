class_name Behaviour_Producer extends Behaviour

@export var production_period:float = 0.5 #how many days the production cycle lasts
@export var inventory := InventoryItemList_float.new()

var lastDate

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lastDate = Globals.WorldTime.world_date


func update():
	var dateDelta = Globals.WorldTime.world_date - lastDate
	if dateDelta < (Globals.WorldTime.world_day_duration * production_period):
		return
	lastDate =  Globals.WorldTime.world_date
	
	for item in entity_storage.inventory.items:
		var produced = inventory.items[item] * dateDelta / Globals.WorldTime.world_day_duration
		entity_storage.inventory.items[item] += produced
