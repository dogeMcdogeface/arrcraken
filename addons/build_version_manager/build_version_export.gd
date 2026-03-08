@tool 
extends EditorExportPlugin 

var BuildVersionManager

func  _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int):
	BuildVersionManager._on_project_exported()

func _get_name():
	return "BuildVersionExportPlugin"
