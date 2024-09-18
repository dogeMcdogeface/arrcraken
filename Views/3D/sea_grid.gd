extends MeshInstance3D

func player_position_updated(p_position, p_rotation):
	get_active_material(0).set_shader_parameter("centerOffset",Vector3 (p_position.x, 0 , p_position.y ) );
