extends Tree
class_name WorldEconomyTable

@onready var economy = Globals.WorldEconomy
@export var priceCurve:PriceCurveGraph

@onready var subcolumns = [
	{
		"title": "Desire",
		"get": func(trader, item): 
			return trader.price_calculators.items[item].stock_target,
		"format": func(v): return "%.0f %s" % v,
		"total": null
	},
	{
		"title": "Amount",
		"get": func(trader, item): 
			return trader.entity_storage.inventory.items.get(item, 0),
		"format": func(v): return "%.0f" % v,
		"total": func(item): 
			return economy.item_list_totals.items.get(item, 0),
	},
	{
		"title": "Value",
		"get": func(trader, item): 
			return trader.price_calculators.items[item].price,
		"format": func(v): return "%.2f" % v,
		"total":  func(item): 
			return economy.item_list_average_price.items.get(item, 0),
	},
	{
		"title": "History",
		"get": func(trader, item):
			return trader.price_calculators.items[item].price_history,
		"format": null,
		"draw": func(item_obj: TreeItem, rect: Rect2, history):
			draw_price_graph(rect, history),
		"total": null
	}
]

var highlighted_row : TreeItem
var highlighted_start_col := -1


func _on_tree_cell_selected():

	var row = get_selected()
	if row == null:
		return

	var col = get_selected_column()

	# ignore trader name column
	if col <= 0:
		return

	var trader_index = row.get_index() - 2
	if trader_index < 0 or trader_index >= economy.traders.size():
		return

	# determine which item group was clicked
	var item_index = (col - 1) / subcolumns.size()
	var item = economy.item_list.items.keys()[item_index]
	var trader: Behaviour_Trader = economy.traders[trader_index]

	priceCurve.price_calculator = trader.price_calculators.items[item]
	
	
	var group_start = 1 + item_index * subcolumns.size()
	highlighted_row = row
	highlighted_start_col = group_start
	# clear existing selection
	deselect_all()


var highlight_style : StyleBoxFlat
var style_normal : StyleBoxFlat


func _ready() -> void:
	resized.connect(_on_resized)
	
	highlight_style = StyleBoxFlat.new()
	highlight_style.border_width_left = 0
	highlight_style.border_width_right = 0
	highlight_style.border_width_top = 1
	highlight_style.border_width_bottom = 1
	highlight_style.bg_color = Color(0.87, 1.0, 0.972, 0.2)
	highlight_style.border_color = Color(0.8, 0.8, 0.8, 0.58)
	
	style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0,0,0,0)
	
	
	cell_selected.connect(_on_tree_cell_selected)
	build_tree_structure()
	pass

func _process(delta: float) -> void:
	if(priceCurve and !priceCurve.price_calculator and !Globals.WorldEconomy.traders.is_empty()):
		priceCurve.price_calculator = Globals.WorldEconomy.traders[0].price_calculators.items[InventoryItemList_PriceCalculator.ITEM_WOOD]

	if(priceCurve and priceCurve.price_calculator):
		for trader in Globals.WorldEconomy.traders:
			var item = priceCurve.price_calculator.item
			priceCurve.dynamic_prices[trader] = trader.price_calculators.items[item]
	
	ensure_trader_rows()
	update_rows()
	update_totals()


func _on_resized():
	var base_width = size.x / columns
	for c in columns:
		set_column_expand(c, true)
		set_column_custom_minimum_width(c, base_width)


var root: TreeItem
var header1: TreeItem
var header2: TreeItem
var total_row: TreeItem

var trader_rows := {}   # trader -> TreeItem

func build_tree_structure():

	clear()

	var item_list = economy.item_list.items

	columns = 1 + item_list.size() * subcolumns.size()
	hide_root = true
	column_titles_visible = false

	root = create_item()

	build_headers(item_list)

	total_row = create_item(root)
	total_row.set_text(0, "TOTAL")
	total_row.set_custom_bg_color(0, Color(0.1,0.1,0.1))


func build_headers(item_list):

	header1 = create_item(root)
	header2 = create_item(root)

	header1.set_text(0, "Trader")

	for c in columns:
		header1.set_selectable(c, false)
		header2.set_selectable(c, false)

	var col := 1

	for item in item_list:
		var text_col := 0

		if subcolumns.size() % 2 == 1:
			text_col = col + subcolumns.size() / 2
			header1.set_text_alignment(text_col, HORIZONTAL_ALIGNMENT_CENTER)
		else:
			text_col = col + (subcolumns.size() / 2) - 1
			header1.set_text_alignment(text_col, HORIZONTAL_ALIGNMENT_RIGHT)

		header1.set_text(text_col, item.display_name)
		header1.set_custom_color(text_col, Color.WHITE)

		var color = Color(0.018,0.018,0.018)

		if (col / subcolumns.size() % 2):
			color = Color(0.069,0.069,0.069)

		for i in subcolumns.size():
			header1.set_custom_bg_color(col + i, color)

		# sub headers
		for s in subcolumns.size():

			var col_def = subcolumns[s]
			header2.set_text(col + s, col_def.title)

			var start_color = Color(0.144,0.144,0.144)
			var end_color = Color(0.248,0.248,0.248)

			var t = float(s) / float(subcolumns.size() - 1)
			var color2 = start_color.lerp(end_color, t)

			header2.set_custom_bg_color(col + s, color2)

		col += subcolumns.size()



func ensure_trader_rows():

	var traders = economy.traders

	for trader in traders:

		if trader_rows.has(trader):
			continue

		# remove total row temporarily so the new row appears before it
		if total_row:
			total_row.free()

		var row = create_item(root)
		row.set_text(0, trader.entity.display_name)
		row.set_selectable(0, false)
		trader_rows[trader] = row

		# recreate total row at the end
		total_row = create_item(root)
		total_row.set_text(0, "TOTAL")
		for c in columns:
			total_row.set_selectable(c, false)
			total_row.set_custom_bg_color(c, Color(0.1,0.1,0.1))

func update_rows():

	var item_list = economy.item_list.items

	for trader in trader_rows.keys():

		var row: TreeItem = trader_rows[trader]

		var col := 1

		for item in item_list:

			for s in subcolumns.size():



				if row == highlighted_row && col == highlighted_start_col:
					row.set_custom_stylebox(col + s, highlight_style)
				else:
					row.set_custom_stylebox(col + s, style_normal)

				var col_def = subcolumns[s]
				var value = col_def.get.call(trader, item)
				

				if col_def.has("draw"):

					row.set_cell_mode(col + s, TreeItem.CELL_MODE_CUSTOM)

					row.set_custom_draw_callback(
						col + s,
						func(item_obj: TreeItem, rect: Rect2):
							col_def.draw.call(item_obj, rect, value)
					)

				elif col_def.has("format"):

					row.set_text(col + s, col_def.format.call(value))

				else:

					row.set_text(col + s, str(value))

			col += subcolumns.size()


func update_totals():

	var item_list = economy.item_list.items

	var col := 1

	for item in item_list:

		for s in subcolumns.size():

			var col_def = subcolumns[s]

			if col_def.total == null:
				continue

			var value = col_def.total.call(item)

			if col_def.has("format"):
				total_row.set_text(col + s, col_def.format.call(value))
			else:
				total_row.set_text(col + s, str(value))


		col += subcolumns.size()


@export var line_color:Color = Color.GREEN
@export var fill_gradient: Gradient

func draw_price_graph(rect: Rect2, history: Array):
	if history.is_empty():
		return

	var min_val := 0
	var max_val = max(history.max(), 500.0)

	var w := rect.size.x
	var h := rect.size.y
	var pos := rect.position
	var count := history.size()
	var bottom_y := pos.y + h

	var poly := PackedVector2Array()
	var colors := PackedColorArray()
	var line_points: Array[Vector2] = []

	for i in range(count):
		var x := pos.x + float(i) / (count - 1) * w
		var v = history[i]
		var y = bottom_y - ((v - min_val) / max(max_val - min_val, 0.01)) * h

		var p := Vector2(x, y)
		poly.append(p)
		colors.append(fill_gradient.sample(1.0 - (y - pos.y) / h))

		line_points.append(p)

	for i in range(count - 1, -1, -1):
		poly.append(Vector2(line_points[i].x, bottom_y))
		colors.append(fill_gradient.sample(0.0))

	if(poly.size()>2):
		draw_polygon(poly, colors)

	for i in range(1, line_points.size()):
		draw_line(line_points[i - 1], line_points[i], line_color, -1, true)

	var price := str(int(history[count - 1]))
	var font := get_theme_font("font")
	var size := get_theme_font_size("font_size")

	var ascent := font.get_ascent(size)
	var descent := font.get_descent(size)
	var text_size := font.get_string_size(price, HORIZONTAL_ALIGNMENT_LEFT, -1, size)

	var center := pos + rect.size * 0.5
	var text_pos := Vector2(center.x - text_size.x * 0.5, center.y + (ascent - descent) * 0.5)

	draw_string(font, text_pos, price, HORIZONTAL_ALIGNMENT_CENTER, -1, size, get_theme_color("font_color"))
