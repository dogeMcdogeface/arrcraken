extends Behavior
class_name NavigationTargetBehavior


func _setup_local_to_scene():
	owner.add_to_group(Globals.NAVTARGETSGROUP)
