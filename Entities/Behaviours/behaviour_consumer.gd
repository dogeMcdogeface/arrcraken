class_name Behaviour_Consumer extends Behaviour

@export_range(0.0, 365.0, 0.1, "suffix:days")
var consumption_interval:float = 2 #how many days the consumption cycle lasts
@onready var world_timer:=WorldTimer.new(consumption_interval)

@export var inventory := InventoryItemList_float.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func update():
	if world_timer.tick(is_paused):
		for item in entity_storage.inventory.items:
			var consumed = inventory.items[item] * world_timer.elapsed_days
			entity_storage.inventory.items[item] -= consumed
