extends Label
class_name VersionLabel

func _ready():
	text = BuildVersion.get_latest_version_string()
