extends StaticBody3D

func player_position_updated(p_position, p_rotation):
	rotation.y = -p_rotation.angle();
