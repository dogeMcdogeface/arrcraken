@tool
class_name WorldMapCity extends WorldMapNavigationTarget

@export var size:int = 0

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
	inventory.produce(production, delta)
	$RichTextLabel.text = inventory.to_string()


################# DEBUG ###############################################################
@export var debug :bool = false
@onready var debug_string = func(): return "\
inventory:	%s 
prices:		%s" % [
	inventory,
	prices,
	]
#######################################################################################
