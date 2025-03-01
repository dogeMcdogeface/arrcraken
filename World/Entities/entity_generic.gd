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
@export var navigation_target_behavior: NavigationTargetBehavior
@export var trader_behavior: TraderBehavior
@export var producer_behavior: ProducerBehavior
@onready var behaviors = get_behaviors()


################# FUNCTIONS ###########################################################
func _ready(): pass
func _process(delta: float) -> void: 
	if Engine.is_editor_hint(): return
	delta = Globals.world_time_scale * delta
	#print("traders", get_tree().get_nodes_in_group("traders"))
	for behavior in behaviors:
		if behavior.has_method("_process"):
			behavior._process(delta)


# Returns all not empty behaviors for the entity
func get_behaviors() -> Array:
	var behaviors_array = []
	for prop in self.get_property_list():
		var value = get(prop.name)
		if value is Behavior:
			behaviors_array.append(value)
	return behaviors_array



################# DEBUG ###############################################################
var debug :bool = true
var debug_string = func(): return "\
inventory : %s
production: %s
prices    : %s
desire    : %s
behaviors    : %s" % [
inventory.to_debug_string(),
producer_behavior.rates.to_debug_string() if producer_behavior else "none",
trader_behavior.prices.to_debug_string() if trader_behavior else "none",
trader_behavior.desire.to_debug_string() if trader_behavior else "none",
behaviors,
]
#######################################################################################
