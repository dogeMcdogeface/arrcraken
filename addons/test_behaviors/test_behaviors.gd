@tool
extends EditorPlugin

var last_warning: String = ""
var collisions: Dictionary = {}
var timer: Timer

func _enter_tree():
	timer = Timer.new()
	timer.wait_time = 1.0  # Set delay between checks (5 seconds)
	timer.one_shot = false  # Set to false for continuous checks
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))  # Correct way to pass method as a Callable
	add_child(timer)  # Add the timer to the plugin

	# Start the timer
	timer.start()

func _exit_tree():
	# Cleanup when the plugin is disabled
	timer.stop()
	remove_child(timer)
	timer.queue_free()

func _on_timer_timeout():
	# This function will be called every time the timer times out (every 5 seconds)
	var scene_tree = get_editor_interface().get_edited_scene_root()
	if not scene_tree:
		return
	
	# Clear the behavior map and check the scene
	var behavior_map: Dictionary = {}

	check_node(scene_tree, behavior_map)
	
	var new_collisions = {}

	for key in behavior_map.keys():
		if behavior_map[key].size() > 1:
			new_collisions[key] = behavior_map[key]
	
	
	
	if (new_collisions != collisions):
		if (new_collisions.is_empty()):
			push_warning("Removed all Shared Behavior from entities")
		else:
			for resource in new_collisions.keys():
				var entities = new_collisions[resource]
				var entity_names = []
				
				# Collect all entity names into a list
				for entity in entities:
					entity_names.append(entity.name)
				
				# Join the entity names with tabs
				var entities_str = ", ".join(entity_names)
				
				# Print a single warning for the resource with all entities involved
				push_warning("Shared Behavior for '%s' in %s" % [resource, entities_str])
			push_warning("Please don't duplicate entities in the world map. Reload project to fix.")
		
		collisions = new_collisions


func check_node(node: Node, behavior_map: Dictionary):
	# Iterate over all properties of the node
	var script = node.get_script()
	if script and script is GDScript:
		var properties = script.get_script_property_list()

		for property in properties:
			var property_name = property.get("name")
			var property_type = property.get("type")

			# Skip built-in properties (those starting with "_")
			if property_name.begins_with("_"):
				continue

			# Get the value of the property
			var property_value = node.get(property_name) if node.has_method("get") else null
			
			# Check if it's a Behavior resource
			var balls :Resource
			#balls.get
			if property_value is Resource and property_value is Behavior:
				property_value = (property_name + str(property_value))
				if !behavior_map.has(property_value):
					behavior_map[property_value]= [node]
				else:
					behavior_map[property_value].append(node)

	# Recursively check all children
	for child in node.get_children():
		check_node(child, behavior_map)
