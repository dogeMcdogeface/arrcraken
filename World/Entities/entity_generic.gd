extends Area2D

################# PROPERTIES ##########################################################
@export var label:String = get_name():
	set(value):
		label = value
		if label == null or label == "":
			label = get_name()

@export var description:String 

@export var disabled:bool = false:  set = set_disabled
func set_disabled(value: bool):
	disabled = value
	modulate = Color.BLACK if disabled else Color.WHITE


################# BEHAVIORS ###########################################################
@export_category("Entity Behaviors")
@export var inventory: Inventory
@onready var behaviors = _discover_behaviors()


################# FUNCTIONS ###########################################################
func _ready(): pass
#func _process(delta: float) -> void: 
	#if Engine.is_editor_hint(): return
	#delta = Globals.world_time_scale * delta


# Returns all not empty behaviors for the entity
func _discover_behaviors() -> Dictionary:
	var behaviors_dict = {}
	for child in self.get_children():
		if child is Behavior:
			behaviors_dict[child.get_script()] = child
	return behaviors_dict



################# DEBUG ###############################################################
var debug :bool = true
var debug_string = func(): return "\
inventory : %s
production: %s
prices    : %s
desires   : %s
behaviors    : %s" % [
inventory.to_debug_string(),
behaviors[ProducerBehavior].rates.to_debug_string() if behaviors.has(ProducerBehavior) else "none",
behaviors[TraderBehavior].prices.to_debug_string() if behaviors.has(TraderBehavior) else "none",
behaviors[TraderBehavior].desires.to_debug_string() if behaviors.has(TraderBehavior) else "none",
behaviors.values(),
]
#######################################################################################
