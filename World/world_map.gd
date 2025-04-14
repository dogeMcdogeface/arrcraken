@tool
extends Area2D

@export var working_resolution = 200
@export var smoothing = 3.0

@export var color_land:Color   = Color8(0,255,0)
@export var color_oceanD:Color = Color8(0,0,255)
@export var color_oceanS:Color = Color8(0,255,255)

@export_category("Debug")
@export var update_polygons = false


@onready var border = $Border

@onready var nav_shallow = $Navigation/NavigationRegion2D_shallow
@onready var nav_deep    = $Navigation/NavigationRegion2D_deep
@onready var nav_land    = $Navigation/NavigationRegion2D_land

@onready var debugpoly_shallow = $DebugPolygons/Shallow
@onready var debugpoly_deep = $DebugPolygons/Deep
@onready var debugpoly_lan = $DebugPolygons/Land


@onready var sprite_logical = $Textures/logical
@onready var sprite_logical_small = $Textures/logical_small


var map_colors = [color_land, color_oceanD, color_oceanS]
var map_polygons = {}

func _process(delta: float) -> void:
	if !Engine.is_editor_hint(): return
	if Engine.get_frames_drawn() % 6:return
	update_texture_sizes()
	generate_polygons()
	
	
func generate_polygons():
	if !update_polygons: return
	var texture_logical = sprite_logical.texture
	var image_logical = texture_logical.get_image()
	image_logical.resize(working_resolution,working_resolution, Image.INTERPOLATE_BILINEAR  )

	sprite_logical_small.texture = ImageTexture.create_from_image(image_logical)
	
	var color_counts = {}
	var color_images = {}
	for color in map_colors:
		color_counts[color] = 0
		color_images[color] = BitMap.new()
		color_images[color].create(Vector2(working_resolution, working_resolution))

	for y in range(image_logical.get_height()):
		for x in range(image_logical.get_width()):
			var pixel_color: Color = image_logical.get_pixel(x, y)

			var min_dist := INF
			var closest_color = null
			
			for ref_color in map_colors:
				var dist = abs(pixel_color.r - ref_color.r)+abs(pixel_color.g - ref_color.g)+abs(pixel_color.b - ref_color.b)
				if dist < min_dist:
					min_dist = dist
					closest_color = ref_color

			if closest_color != null:
				color_counts[closest_color] +=1
				color_images[closest_color].set_bit(x, y, true)

	var scale = Globals.WorldMapSize / Vector2(working_resolution,working_resolution) 
	var offset = Globals.WorldMapSize / 2
	var new_map_polygons = {}

	print("Generating polygons")
	for color in map_colors:
		var new_polys = color_images[color].opaque_to_polygons(Rect2(Vector2(), color_images[color].get_size()), smoothing)
		for i in new_polys.size():
			var poly = new_polys[i]
			var newPoly =[]
			for vec in poly:
				newPoly.append(vec * scale - offset)
			new_polys[i] =  PackedVector2Array( newPoly)
		new_map_polygons[color] = new_polys

	if !map_polygons.recursive_equal(new_map_polygons, 4):
		map_polygons = new_map_polygons
		print("polygons changed")
		generate_navigation_mesh()
	generate_debug_polygons()
		


func generate_debug_polygons():
	print("run")
	var array = []
	for n in nav_shallow.navigation_polygon.get_polygon_count():
		array.append(nav_shallow.navigation_polygon.get_polygon(n))
	debugpoly_shallow.set_polygons(array)
	debugpoly_shallow.set_polygon(nav_shallow.navigation_polygon.get_vertices())

	array = []
	for n in nav_deep.navigation_polygon.get_polygon_count():
		array.append(nav_deep.navigation_polygon.get_polygon(n))
	debugpoly_deep.set_polygons(array)
	debugpoly_deep.set_polygon(nav_deep.navigation_polygon.get_vertices())
	
	array = []
	for n in nav_land.navigation_polygon.get_polygon_count():
		array.append(nav_land.navigation_polygon.get_polygon(n))
	debugpoly_lan.set_polygons(array)
	debugpoly_lan.set_polygon(nav_land.navigation_polygon.get_vertices())




func generate_navigation_mesh():
	var allObstacles = []
	allObstacles.append_array(map_polygons[color_land])
	allObstacles.append_array(map_polygons[color_oceanD])
	
	
	var navigation_shallow = NavigationPolygon.new()
	navigation_shallow.add_outline(border.polygon)
	var NavMeshGeom_shallow = NavigationMeshSourceGeometryData2D.new()
	NavMeshGeom_shallow.append_obstruction_outlines(allObstacles)
	NavigationServer2D.bake_from_source_geometry_data(navigation_shallow, NavMeshGeom_shallow);
	nav_shallow.navigation_polygon = navigation_shallow
	
	
	var navigation_deep = NavigationPolygon.new()
	var NavMeshGeom_deep = NavigationMeshSourceGeometryData2D.new()
	NavMeshGeom_deep.set_traversable_outlines(map_polygons[color_oceanD])
	NavigationServer2D.bake_from_source_geometry_data(navigation_deep, NavMeshGeom_deep);
	nav_deep.navigation_polygon = navigation_deep

	var navigation_land = NavigationPolygon.new()
	var NavMeshGeom_land = NavigationMeshSourceGeometryData2D.new()
	NavMeshGeom_land.set_traversable_outlines(map_polygons[color_land])
	NavigationServer2D.bake_from_source_geometry_data(navigation_land, NavMeshGeom_land);
	nav_land.navigation_polygon = navigation_land

	return

	


func create_nav_obstacles(dad, polys):
	var children = dad.get_children()
	for child in children:
		child.free()
	for poly in polys:
		var newpoly = NavigationObstacle2D.new()
		newpoly.affect_navigation_mesh = true
		newpoly.vertices  = poly
		dad.add_child(newpoly)
		newpoly.set_owner(get_tree().get_edited_scene_root())



func update_texture_sizes():
	border.polygon = [
		Vector2( Globals.WorldMapSize) /2 ,
		Vector2( Globals.WorldMapSize).reflect(Vector2(1,0))/2 ,
		Vector2( Globals.WorldMapSize)/-2 ,
		Vector2( Globals.WorldMapSize).reflect(Vector2(0,1))/2 ,
	]
	
	sprite_logical.scale = Globals.WorldMapSize/sprite_logical.texture.get_size()
	sprite_logical_small.scale = Globals.WorldMapSize/sprite_logical_small.texture.get_size()
