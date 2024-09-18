extends Control

func _on_wind_updated( wind: Vector2):
		$arrow.rotation = wind.angle()
		$arrow.scale = Vector2(wind.length(),wind.length())
		
