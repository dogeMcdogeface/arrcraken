extends MarginContainer

@onready var economy = Globals.WorldEconomy
@onready var tree = $TabContainer/Tree
@onready var priceCurve := $TabContainer/PriceCurveGraph
var root 

func _ready() -> void:
	tree.cell_selected.connect(_on_tree_cell_selected)
	pass


func _on_tree_cell_selected():
	var selected_row = tree.get_selected()
	var trader_index = selected_row.get_index() - 2
	if selected_row == null or trader_index < 0 or trader_index >= economy.traders.size():
		return

	var item_index = (tree.get_selected_column() - 1) / subcolumns.size()
	var item = economy.item_list.items.keys()[item_index]
	var trader:Behaviour_Trader = economy.traders[trader_index]

	#print(trader.entity.display_name, " ", item)
	priceCurve.price_calculator = trader.price_calculators.items[item]



func _process(delta: float) -> void:
	if(!priceCurve.price_calculator and !Globals.WorldEconomy.traders.is_empty()):
		priceCurve.price_calculator = Globals.WorldEconomy.traders[0].price_calculators.items[InventoryItemList_PriceCalculator.ITEM_WOOD]

	if(priceCurve.price_calculator):
		for trader in Globals.WorldEconomy.traders:
			var item = priceCurve.price_calculator.item
			priceCurve.dynamic_prices[trader] = trader.price_calculators.items[item]
	
	update_tree()


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




func update_tree():

	var item_list = economy.item_list.items
	var traders = economy.traders 

	tree.clear()

	tree.columns = 1 + item_list.size() * subcolumns.size()
	tree.hide_root = true

	var root = tree.create_item()
	tree.column_titles_visible = false

	# --------------------------------------------------
	# HEADER ROW 1 (RESOURCE GROUPS)
	# --------------------------------------------------

	var header1 = tree.create_item(root)
	header1.set_text(0, "Trader")

	var col := 1
	for item in item_list:

		var text_col := 0
		if subcolumns.size() % 2 == 1:
			# odd -> middle column
			text_col = col + subcolumns.size() / 2
			header1.set_text_alignment(text_col, HORIZONTAL_ALIGNMENT_CENTER)
		else:
			# even -> first half column (left of center pair)
			text_col = col + (subcolumns.size() / 2) - 1
			header1.set_text_alignment(text_col, HORIZONTAL_ALIGNMENT_RIGHT)
		header1.set_text(text_col, item.display_name)


		header1.set_custom_color(text_col, Color.WHITE)
		
		var color = Color(0.018, 0.018, 0.018, 1.0)
		if (col/subcolumns.size() % 2):
			color = Color(0.069, 0.069, 0.069, 1.0)
		
		for i in subcolumns.size():
			header1.set_custom_bg_color(col + i, color)

		col += subcolumns.size()


	# --------------------------------------------------
	# HEADER ROW 2 (AMOUNT / VALUE)
	# --------------------------------------------------

	var header2 = tree.create_item(root)

	col = 1
	for item in item_list:

		for s in subcolumns.size():
			var col_def = subcolumns[s]
			header2.set_text(col + s, col_def.title)

		var start_color = Color(0.144, 0.144, 0.144, 1.0)
		var end_color = Color(0.248, 0.248, 0.248, 1.0)
		for i in subcolumns.size():
			var t = float(i) / float(subcolumns.size() - 1)
			var color = start_color.lerp(end_color, t)
			header2.set_custom_bg_color(col + i, color)

		col += subcolumns.size()



	# --------------------------------------------------
	# DATA
	# --------------------------------------------------

	for trader: Behaviour_Trader in traders:

		var row = tree.create_item(root)
		row.set_text(0, trader.entity.display_name)

		col = 1

		for item in item_list:

			for s in subcolumns.size():
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


	# --------------------------------------------------
	# TOTAL ROW
	# --------------------------------------------------

	var total_row = tree.create_item(root)
	total_row.set_text(0, "TOTAL")
	total_row.set_custom_bg_color(0, Color(0.1,0.1,0.1))

	col = 1


	for item in item_list:
		for s in subcolumns.size():
			var col_def = subcolumns[s]
			if col_def.total == null:
				continue
			var value =  col_def.total.call(item)
			if col_def.has("format"):
				total_row.set_text(col + s, col_def.format.call(value))
			else:
				total_row.set_text(col + s, str(value))
		# darker background so it stands out
		for s in subcolumns.size():
			total_row.set_custom_bg_color(col + s, Color(0.1,0.1,0.1))

		col += subcolumns.size()



func draw_price_graph(rect: Rect2, history: Array):
	if history.is_empty():
		return

	var min_val = 0
	var max_val = max(history.max(), 500)

	if max_val == min_val:
		max_val += 0.001

	var w = rect.size.x
	var h = rect.size.y
	var count = history.size()

	var prev_point: Vector2

	for i in range(count):
		var x = rect.position.x + (float(i) / (count - 1)) * w
		var v = history[i]

		var y_norm = (v - min_val) / (max_val - min_val)
		var y = rect.position.y + h - y_norm * h

		var p = Vector2(x, y)

		if i > 0:
			tree.draw_line(prev_point, p, Color.GREEN, 1.5)

		prev_point = p
