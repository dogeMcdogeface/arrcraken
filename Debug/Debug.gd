extends Node


@export var debug_interval = 0.1

var debug_window

var debuggable_nodes
var debug_string_last
var debug_elapsed = 0

var warning_duration = 5000
var duration_visual_v = ["█", "▇", "▆", "▅", "▄", "▃", "▂", "▁", " "]
var duration_visual_h = ["█", "▉", "▊", "▋", "▌", "▍", "▎", "▏", " "]

func _ready():
	debuggable_nodes = GetAllTreeNodes()
	print(debuggable_nodes)
	debug_window = preload("res://Debug/debug_window.tscn").instantiate()
	add_child(debug_window)
	pass

func _process(delta):
	debug_elapsed += delta
	if debug_interval > debug_elapsed: return
	debug_elapsed = 0


	var debug_string_new = ""
	for node in debuggable_nodes:
		debug_string_new += "-----------  %-20s -----------------\n" % node.get_name()
		if "debug_string" in node and "debug_args" in node:
			debug_string_new += node.debug_string % node.debug_args.call() 
		elif "debug_string" in node:
			debug_string_new += str(node.debug_string.call() )
		elif "debug_args" in node:
			debug_string_new += node.debug_args.call()
		else:
			debug_string_new += node
		debug_string_new += "\n"
		
	if warn_list.size() > 0:
		debug_string_new += "[color=orange]-----------  %-20s -----------------[/color]" % "Warnings"
	for warning in warn_list:
			debug_string_new += "\n[color=orange]%s %s[/color]" % [get_timed_visual_block(warning.time, warning_duration), warning.text]
		
	remove_warnings()


	if(debug_string_last != debug_string_new):
		debug_string_last = debug_string_new 
		debug_window.TextArea.text = debug_string_new
		#clear_console()
		#print_rich(debug_string_new)

func clear_console():
	for i in range(10):
		print()


func get_timed_visual_block(curr_time, max_time):
	var elapsed_ratio = clamp(float(Time.get_ticks_msec() - curr_time) / max_time, 0, 1)
	return duration_visual_v[int(elapsed_ratio * (duration_visual_v.size() - 1))]




var warn_list = []
func warn(text):
	var final_text = ""
	if text is Array:
		final_text = String(" ").join(text.map(func(e): return str(e)))
	else:
		final_text = str(text)

	warn_list.append({"text": final_text, "time": Time.get_ticks_msec()})

func remove_warnings():
	warn_list = warn_list.filter(func(warning):
		return Time.get_ticks_msec() - warning.time <= warning_duration
	)

	

func GetAllTreeNodes(node = get_tree().root, listOfAllNodesInTree = []):
	if("debug" in node and node.debug == true):
		listOfAllNodesInTree.append(node)
	for childNode in node.get_children():
		GetAllTreeNodes(childNode, listOfAllNodesInTree)
	return listOfAllNodesInTree


const wind_directions = [ "nw", "n", "ne", "e", "se", "s", "w",]
const wind_arrows     = ["↖", "↑", "↗", "→", "↘", "↓", "↙"]
func get_heading_info(value):
	var angle : float
	var index : int

	if typeof(value) == TYPE_VECTOR2:
		angle = value.angle()
		index = int(remap(angle, -PI, PI, 0, wind_directions.size() - 1))
	else:
		angle = value
		index = int(remap(angle, -PI, PI, 0, wind_directions.size()))
	
	return {
		"rad": angle,
		"deg": rad_to_deg(angle),
		"dir": wind_directions[index],
		"arrow": wind_arrows[index]
	}



# Seed for color generation to ensure consistent color results across runs
var color_seed = 12345666
func get_unique(node: Node) -> Dictionary:
	var node_id = str(node.get_instance_id())
	var hash_value = hash(node_id + str(color_seed))
	var number = int(hash_value) 
	var color = Color.from_hsv((hash_value % 137)/ 137., 0.8, 0.8)  # Generate color from hash

	return {
		"number": number,
		"color": color
	}


	
@export var debug :bool = true
var debug_string = "debuggable_nodes: %s fps: %-10.3f pps: %-10.3f"
@onready var debug_args = func(): return [
	debuggable_nodes.size(),
	Engine.get_frames_per_second(),
	Engine.physics_ticks_per_second
	]
