@tool
extends NavigationObstacle2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if !Engine.is_editor_hint():
		$StaticBody2D/CollisionPolygon2D.polygon = vertices
