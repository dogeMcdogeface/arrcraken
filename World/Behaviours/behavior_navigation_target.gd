extends Behavior
class_name NavigationTargetBehavior


func _ready():
	owner.add_to_group(Globals.NAVTARGETGROUP)
