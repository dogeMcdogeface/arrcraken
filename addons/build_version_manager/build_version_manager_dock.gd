@tool
extends MarginContainer

var BuildVersionManager
var gui = EditorInterface.get_base_control()


@onready var version_label = $VBoxContainer/HBoxContainer/Label_curr_version
@onready var date_label = $VBoxContainer/ScrollContainer/GridContainer/Label_date
@onready var grid_container = $VBoxContainer/ScrollContainer/GridContainer
@onready var friendly_input = $VBoxContainer/ScrollContainer/GridContainer/LineEdit_friendly
@onready var checkbox_save = $VBoxContainer/GridContainer/Checkbox_sub_on_save
@onready var checkbox_export = $VBoxContainer/GridContainer/Checkbox_sub_on_export

func _ready():
	pass

func update():
	version_label.text = BuildVersion.get_latest_version_string()
	date_label.text = _format_time_now()

	# Clear previous version labels using the group "version_row"
	for child in grid_container.get_children():
		if child.is_in_group("version_row"):
			grid_container.remove_child(child)
			child.queue_free()

	# Add new version labels
	for i in BuildVersionManager.versions.size():
		var version = BuildVersionManager.versions[ BuildVersionManager.versions.size() -1 - i]
		var labels = create_version_labels(version)
		for label in labels:
			label.add_to_group("version_row")
			grid_container.add_child(label)


func create_version_labels(version: Dictionary) -> Array:
	var labels := []

	var major_label := Label.new()
	major_label.text = "%d" % version.get("major", 0)
	labels.append(major_label)

	var minor_label := Label.new()
	minor_label.text = "%d" % version.get("minor", 0)
	labels.append(minor_label)

	var sub_label := Label.new()
	sub_label.text = "%d" % version.get("sub", 0)
	labels.append(sub_label)

	var name_label := Label.new()
	name_label.text = "%s" % version.get("friendly_name", "Unnamed Version")
	labels.append(name_label)

	var timestamp := version.get("release_timestamp", Time.get_unix_time_from_system())
	var readable_time = BuildVersionManager.get_readable_time(timestamp)
	var time_label := Label.new()
	time_label.text = "%s" % readable_time
	labels.append(time_label)
	return labels

func _format_time_now() -> String:
	var now := Time.get_datetime_dict_from_system()
	var formatted := "%02d/%02d/%02d %02d:%02d" % [
		now.day, now.month, now.year % 100, now.hour, now.minute
	]
	return formatted


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


func _on_button_version_pressed(type: String) -> void:
	BuildVersionManager.increment_version(type, friendly_input.text)
	friendly_input.text = ""

func _on_button_major_pressed(): _on_button_version_pressed("major")
func _on_button_minor_pressed(): _on_button_version_pressed("minor")
func _on_button_sub_pressed(): _on_button_version_pressed("sub")

func _on_button_reset_pressed() -> void:
	BuildVersionManager.reset_version_history()

func increment_on_save():
	return checkbox_save.button_pressed 
func increment_on_export():
	return checkbox_export.button_pressed 
