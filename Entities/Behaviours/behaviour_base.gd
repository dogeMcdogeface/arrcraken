class_name Behaviour extends Node

@export var is_paused:bool = false

## Interval between behaviour updates.
## Measured in world days.
## Set to -1 to disable updates.
@export_range(-1.0, 365.0, 0.1, "suffix:days")
var update_interval: float = 1
#var world_timer:=WorldTimer.new()


var entity: Entity
var entity_storage: Behaviour_Storage:
	get:
		if entity and entity.behaviours.has(Behaviour_Storage):
			return entity.behaviours[Behaviour_Storage]
		return null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.BehaviourManager.register_behaviour(self)
	pass # Replace with function body.


func process_tick(world_timer:WorldTimer):
	pass
