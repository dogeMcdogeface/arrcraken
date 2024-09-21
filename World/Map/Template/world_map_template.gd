@tool
extends Container
class_name WorldMap

@onready var shallow_water = $shallow_water
@onready var deep_water = $deep_water
@onready var visual_shallow_water = $debug/visual_shallow_water
@onready var visual_deep_water = $debug/visual_deep_water
@onready var visual_connection_water = $debug/visual_connection_water


# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		update_configuration_warnings()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if  Engine.get_process_frames() % 60 == 0:
		if $debug.visible:
			update_debug_navigation_visuals()
		


var old_gateway_polygon = []
func update_debug_navigation_visuals():
	var array = []
	for n in shallow_water.navigation_polygon.get_polygon_count():
		array.append(shallow_water.navigation_polygon.get_polygon(n))
	visual_shallow_water.set_polygons(array)

	array = []
	for n in deep_water.navigation_polygon.get_polygon_count():
		array.append(deep_water.navigation_polygon.get_polygon(n))
	visual_deep_water.set_polygons(array)

	visual_shallow_water.set_polygon(shallow_water.navigation_polygon.get_vertices())
	visual_deep_water.set_polygon(deep_water.navigation_polygon.get_vertices())

#TODO clean up
	array = []
	var map = get_world_2d().get_navigation_map()
	var regions = NavigationServer2D.map_get_regions(map)
	var conn_count = NavigationServer2D.region_get_connections_count( regions[0])
	for n in conn_count:
		array.append([Vector2(NavigationServer2D.region_get_connection_pathway_start(regions[0], n)),Vector2(NavigationServer2D.region_get_connection_pathway_end(regions[0], n))])

	if old_gateway_polygon.hash() != array.hash():
		old_gateway_polygon = array
		
		var children = visual_connection_water.get_children()
		for child in children:
			child.queue_free()
		for n in array:
			var line = Line2D.new()
			line.default_color = visual_connection_water.default_color
			line.width =  visual_connection_water.width
			line.texture =   visual_connection_water.texture
			line.texture_mode =   visual_connection_water.texture_mode
			line.texture_repeat =   visual_connection_water.texture_repeat
			visual_connection_water.add_child(line)
			line.add_point(n[0])
			line.add_point(n[1])

		#var map = get_world_2d().get_navigation_map()
		#var regions = NavigationServer2D.map_get_regions(map)
		#print(World2D ,NavigationServer2D.map_get_regions(maps[0])[0].get_id())
	
