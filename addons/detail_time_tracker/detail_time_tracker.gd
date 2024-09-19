@tool
extends EditorPlugin

const settings_path = "res://addons/detail_time_tracker/record.json"
var dock : DetailTimeTrackerDock

var activities = {
	"outside": .0,
	"playing": .0,
	"other":.0,
	"editing":{
		"script":{},
		"control":{},
		"node2D":{},
		"node3D":{},
		"object":{},
	}
}

func _enter_tree():
	if FileAccess.file_exists(settings_path):
		var save_file = FileAccess.open(settings_path, FileAccess.READ)
		while save_file.get_position() < save_file.get_length():
			var json_string = save_file.get_line()
			var json = JSON.new()

			var parse_result = json.parse(json_string)
			if not parse_result == OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
				continue
			else:
				activities = json.get_data()
	
	main_screen_changed.connect(on_main_screen_changed)
	
	dock = preload("res://addons/detail_time_tracker/detail_time_tracker_dock.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)

func _exit_tree():
	remove_control_from_docks(dock)
	# Erase the control from the memory.
	dock.free()

var elapsed_time = 0
var update_interval = 1
func _process(delta):
	if !Engine.is_editor_hint():return
	elapsed_time += delta
	if elapsed_time < update_interval:return
	delta = elapsed_time
	elapsed_time = 0
	var editing_node = EditorInterface.get_edited_scene_root()
	var editing_node_name = "unknown_node"
	if editing_node != null and editing_node.has_method("get_name"):
		editing_node_name = editing_node.get_name()
	var editing_script = EditorInterface.get_script_editor().get_current_script()
	
	var is_focused = false
	var is_playing = EditorInterface.get_playing_scene() != ""
	for id in DisplayServer.get_window_list():
		if DisplayServer.window_is_focused(id):
			is_focused = true
			break
	
	if is_focused:
		if current_screen == "Script":
			if editing_script != null and "resource_path" in editing_script :
				activities.editing.script.get_or_add(editing_script.resource_path, 0)
				activities.editing.script[editing_script.resource_path] += delta
			else:
				activities.editing.script.get_or_add("unknown_file", .0)
				activities.editing.script["unknown_file"] += delta
		elif current_screen == "2D" || current_screen == "3D": 
			if editing_node is Control:
				activities.editing.control.get_or_add(editing_node_name, .0)
				activities.editing.control[editing_node_name] += delta
			elif editing_node is Node2D:
				activities.editing.node2D.get_or_add(editing_node_name, .0)
				activities.editing.node2D[editing_node_name] += delta
			elif editing_node is Node3D:
				activities.editing.node3D.get_or_add(editing_node_name, .0)
				activities.editing.node3D[editing_node_name] += delta
			else:
				activities.editing.object.get_or_add(editing_node_name, .0)
				activities.editing.object[editing_node_name] += delta
		else:
			activities.other += delta
	elif is_playing:
		activities.playing += delta
	else:
		activities.outside += delta
	#print(activities)
	dock.update(activities, get_aggregate_time)
	var save_file = FileAccess.open(settings_path, FileAccess.WRITE)
	var json_string = JSON.stringify(activities)
	save_file.store_line(json_string)
	


func get_aggregate_time(dict):
	if dict is float:
		return dict
	else:
		var sum = .0
		for key in dict:
			sum += get_aggregate_time(dict[key])
		return sum

var current_screen = ""
func on_main_screen_changed(screen):
	current_screen = screen
	
