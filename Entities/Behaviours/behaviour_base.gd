class_name Behaviour extends Node

@export var is_paused:bool = false

#@export_range(0.0, 365.0, 0.1, "suffix:days")
#var update_interval: float = 2
#var world_timer:=WorldTimer.new()


var entity: Entity
var entity_storage: Behaviour_Storage:
	get:
		if entity and entity.behaviours.has(Behaviour_Storage):
			return entity.behaviours[Behaviour_Storage]
		return null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func update():
	pass


func _on_entity_set(_entity: Entity):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
