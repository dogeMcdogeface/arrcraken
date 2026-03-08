@tool
extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Game running on version ", get_latest_version_string())
	pass # Replace with function body.


func version_to_string(version: Dictionary) -> String:
	var major = version.get("major", 0)
	var minor = version.get("minor", 0)
	var sub = version.get("sub", 0)
	var name = version.get("friendly_name", "Unnamed")
	return "%d.%d.%d (%s)" % [major, minor, sub, name]


func get_latest_version() -> Dictionary:
	return (ProjectSettings.get_setting("application/config/version", ""))
func get_latest_version_string() -> String:
	return version_to_string(get_latest_version())
