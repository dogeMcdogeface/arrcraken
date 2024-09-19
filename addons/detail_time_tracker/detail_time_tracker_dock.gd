@tool
extends MarginContainer
class_name DetailTimeTrackerDock

var gui = EditorInterface.get_base_control()

func _ready():
	$Tree.columns = 2
	$Tree.column_titles_visible = true
	$Tree.hide_root = false
	$Tree.set_column_expand(0, true)
	$Tree.set_column_expand(1, false)
	$Tree.set_column_title(0, "Item")
	$Tree.set_column_title(1, "Time")
	$Tree.add_theme_constant_override("draw_relationship_lines", 0 )

func update(dict : Dictionary, get_aggregate_time:Callable): 
	$Tree.clear()
	
	var root = $Tree.create_item()
	root.set_text(0, "Total Time on Project")
	root.set_icon(0,  title_to_icon("Total Time on Project"))
	root.set_text(1, _format_time(get_aggregate_time.call(dict)))
	root.set_text_overrun_behavior(1, TextServer.OVERRUN_NO_TRIMMING )

	recursive_tree_build(dict, root, get_aggregate_time)
	root.call_recursive("set_text_alignment", 1, HORIZONTAL_ALIGNMENT_RIGHT )


func recursive_tree_build(dict, root, get_aggregate_time):
	var keys = dict.keys()
	keys.sort_custom(func(x: String, y: String) -> bool: 
		if x.contains("other") or x.contains("unknown"):
			return false
		if y.contains("other") or y.contains("unknown"):
			return true
		if dict[x] is float and dict[y] is Dictionary:
			return true
		if dict[y] is float and dict[x] is Dictionary:
			return false
		return x < y)
		
	for e in keys:
		var line = $Tree.create_item(root)
		line.set_text(0, e)
		line.set_icon(0, title_to_icon(e))
		if dict[e] is float:
			line.set_text(1, _format_time(dict[e]))
		elif dict[e] is Dictionary:
			line.set_text(1, _format_time(get_aggregate_time.call(dict[e])))
			recursive_tree_build(dict[e], line, get_aggregate_time)


func title_to_icon(text):
	match text:
		"Total Time on Project": return gui.get_theme_icon("Time", "EditorIcons")
		"editing": return gui.get_theme_icon("3D", "EditorIcons")
		"control": return gui.get_theme_icon("Control", "EditorIcons")
		"node2D": return gui.get_theme_icon("Node2D", "EditorIcons")
		"node3D": return gui.get_theme_icon("Node3D", "EditorIcons")
		"object": return gui.get_theme_icon("Object", "EditorIcons")
		"script": return gui.get_theme_icon("Script", "EditorIcons")
		"playing": return gui.get_theme_icon("MainPlay", "EditorIcons")
		"outside": return gui.get_theme_icon("MakeFloating", "EditorIcons")
		"other": return gui.get_theme_icon("AssetLib", "EditorIcons")
		"unknown_node": return gui.get_theme_icon("ObjectDisabled", "EditorIcons")
		"unknown_file": return gui.get_theme_icon("File", "EditorIcons")
	return gui.get_theme_icon("Mouse", "EditorIcons")

func _format_time(t: float) -> String:
	var seconds = int(t) % 60
	var minutes = int(t) / 60 % 60
	var hours = int(t) / 3600 % 24
	var days = int(t) / 86400
	
	if days > 0:
		return "%sd %sh %sm %ss" % [days, hours, minutes, seconds]
	if hours > 0:
		return "%sh %sm %ss" % [hours, minutes, seconds]
	if minutes > 0:
		return "%sm %ss" % [minutes, seconds]
	return "%ss" % [int(t) % 60]
