class_name Behaviour_Producer extends Behaviour

@export_range(0.0, 365.0, 0.1, "suffix:days")
var production_interval:float = 0.5 #how many days the production cycle lasts
@onready var world_timer:=WorldTimer.new(production_interval)

@export var inventory := InventoryItemList_float.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func update():
	if world_timer.tick(is_paused):
		for item in entity_storage.inventory.items:
			var produced = inventory.items[item] * world_timer.elapsed_days
			entity_storage.inventory.items[item] += produced
			
