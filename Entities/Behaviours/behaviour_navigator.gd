class_name Behaviour_Navigator extends Behaviour



func process_tick(world_timer:WorldTimer):
	var agent:NavigationAgent2D = entity.get_node("%NavigationAgent2D")
	var target = Globals.WorldEconomy.traders[0].entity
	var sail = get_behaviour(Behaviour_Sail)
	
	agent.target_position = target.global_position
	var next_position := agent.get_next_path_position()
	#print(next_position, "	", entity.global_position)
	
	
	var direction: Vector2 = next_position - entity.global_position
	sail.target_rotation = direction.angle()
	#print(target.position, " ",agent)
	#print(world_timer.elapsed_days)
	pass
