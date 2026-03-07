extends MarginContainer

@onready var economy = Globals.WorldEconomy
@onready var tree = $Tree
var root 

func _ready() -> void:
	pass


func _process(delta: float) -> void:
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
			return trader.entity.inventory.items.get(item, 0),
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
		var i = 0

		for item in item_list:

			for s in subcolumns.size():
				var col_def = subcolumns[s]
				var value = col_def.get.call(trader, item)
				if col_def.has("format"):
					row.set_text(col + s, col_def.format.call(value))
				else:
					row.set_text(col + s, str(value))

			col += subcolumns.size()
			i += 1


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
