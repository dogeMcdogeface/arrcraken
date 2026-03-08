extends Control
class_name PriceCurveGraph


@export var price_calculator: PriceCalculator

@export_group("Graph")

@export var resolution := 1.0

@export var x_axis_label := "Stock Amount"
@export var y_axis_label := "Price"

# margins for autoscale
@export var x_margin_ratio := 0.1
@export var y_margin_ratio := 0.1

@export var show_markers := true
@export var marker_line_width := 2


@export var font_size := 12
@export var font:Font

@export var region_gradient: Gradient


var dynamic_prices = {}

func get_region_color(index:int, total:int) -> Color:
	if region_gradient == null:
		return Color.WHITE

	var t = float(index) / max(total - 1, 1)
	var saturated = region_gradient.sample(t)
	saturated.s = 1
	return saturated


var _last_hash: int = 0
func _process(delta):
	if !is_instance_valid(price_calculator):
		return
	
	var groups = _extract_groups()
	if groups.is_empty():
		return

	var new_hash = hash(groups)
	
	if new_hash != _last_hash:
		_last_hash = new_hash
		queue_redraw()




func _extract_groups() -> Dictionary:
	var groups := {}
	var current_group := ""
	
	if !is_instance_valid(price_calculator):
		return groups
		
	for prop in price_calculator.get_property_list():

		if prop.usage == PROPERTY_USAGE_GROUP:
			current_group = prop.name
			groups[current_group] = []
			continue

		if !(prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
			continue

		if prop.type not in [TYPE_FLOAT, TYPE_INT]:
			continue

		if current_group == "":
			continue

		groups[current_group].append({
			"name": prop.name,
			"value": price_calculator.get(prop.name)
		})

	return groups


func world_to_screen_x(x: float, x_min: float, x_max: float, w: float) -> float:
	return (x - x_min) / (x_max - x_min) * w


func world_to_screen_y(y: float, y_min: float, y_max: float, h: float) -> float:
	return h - (y - y_min) / (y_max - y_min) * h
	

func nice_tick_size(range: float) -> float:
	var rough = range / 8.0
	var exponent = floor(log(rough) / log(10))
	var base = pow(10, exponent)

	var fraction = rough / base

	if fraction < 1.5:
		return 1 * base
	elif fraction < 3:
		return 2 * base
	elif fraction < 7:
		return 5 * base
	else:
		return 10 * base


func _draw():
	if !is_instance_valid(price_calculator):
		return

	var groups = _extract_groups()

	if groups == {}:
		return
	
	var tmp_price_calculator:PriceCalculator = price_calculator.duplicate()
	tmp_price_calculator.global_market_influence = 0

	var stock_ranges = groups.get("Stock Ranges", [])
	var price_ranges = groups.get("Price Ranges", [])

	if stock_ranges.is_empty() or price_ranges.is_empty():
		return

	var ranges_max = max(stock_ranges.size(), price_ranges.size())


	var w = size.x
	var h = size.y

	# --- find max stock ---
	var max_stock := 0.0
	for s in stock_ranges:
		max_stock = max(max_stock, s.value)

	# --- sample curve to find Y range ---
	var samples := 400
	var min_price := INF
	var max_price := -INF
	var min_x := 0.0

	for i in range(samples + 1):
		var x = (float(i) / samples) * max_stock
		var p = tmp_price_calculator.calculate_price(x, true)

		if p < min_price:
			min_price = p
			min_x = x

		if p > max_price:
			max_price = p

	# --- autoscale ---
	var y_pad = (max_price - min_price) * y_margin_ratio
	var y_min = min_price - y_pad
	var y_max = max_price + y_pad

	var x_min = -max_stock * x_margin_ratio
	var x_max = min_x + max_stock * x_margin_ratio


	# --- sort stock ranges by value ---
	stock_ranges.sort_custom(func(a,b): return a.value < b.value)

	# --- draw regions dynamically ---
	for i in range(stock_ranges.size()):

		var x0 = 0.0 if i == 0 else stock_ranges[i-1].value
		var x1 = stock_ranges[i].value

		var color = get_region_color(i, ranges_max)

		draw_region(x0, x1, color, x_min, x_max, w, h)

	# --- Tick sizes ---
	var x_range = x_max - x_min
	var y_range = y_max - y_min

	var x_tick = nice_tick_size(x_range)
	var y_tick = nice_tick_size(y_range)

	var grid_color = Color(0.65, 0.65, 0.65, 0.235)
	var axis_color = Color.WHITE
	var tick_color = Color.WHITE


	# --- Vertical grid + X ticks ---
	var x_start = floor(x_min / x_tick) * x_tick
	var x_end = ceil(x_max / x_tick) * x_tick

	for x in range(int(x_start / x_tick), int(x_end / x_tick) + 1):
		var xv = x * x_tick
		var px = world_to_screen_x(xv, x_min, x_max, w)

		draw_line(Vector2(px,0), Vector2(px,h), grid_color)

		if 0 >= y_min and 0 <= y_max:
			var py = world_to_screen_y(0, y_min, y_max, h)

			draw_line(Vector2(px,py-5), Vector2(px,py+5), tick_color,2)

			if font:
				draw_string(
					font,
					Vector2(px + 4, py + 16),
					str(round(xv)),
					HORIZONTAL_ALIGNMENT_LEFT,
					-1,
					font_size
				)

	# --- Horizontal grid + Y ticks ---
	var y_start = floor(y_min / y_tick) * y_tick
	var y_end = ceil(y_max / y_tick) * y_tick

	for y in range(int(y_start / y_tick), int(y_end / y_tick) + 1):
		var yv = y * y_tick
		var py = world_to_screen_y(yv, y_min, y_max, h)

		draw_line(Vector2(0,py), Vector2(w,py), grid_color)

		if 0 >= x_min and 0 <= x_max:
			var px = world_to_screen_x(0, x_min, x_max, w)

			draw_line(Vector2(px-5,py), Vector2(px+5,py), tick_color,2)

			if font:
				draw_string(
					font,
					Vector2(px + 6, py - 4).floor(),
					str(round(yv)),
					HORIZONTAL_ALIGNMENT_LEFT,
					-1,
					font_size
				)

	# --- Axes ---
	if 0 >= x_min and 0 <= x_max:
		var px = world_to_screen_x(0, x_min, x_max, w)
		draw_line(Vector2(px,0), Vector2(px,h), axis_color, 2)

	if 0 >= y_min and 0 <= y_max:
		var py = world_to_screen_y(0, y_min, y_max, h)
		draw_line(Vector2(0,py), Vector2(w,py), axis_color, 2)


	# --- draw curve ---
	var prev := Vector2.ZERO
	var steps := int(w) * resolution

	for i in range(steps):

		var t = float(i) / (steps - 1)
		var x = lerp(x_min, x_max, t)
		var price := tmp_price_calculator.calculate_price(x, true)

		var px = world_to_screen_x(x, x_min, x_max, w)
		var py = world_to_screen_y(price, y_min, y_max, h)

		var p := Vector2(px, py)

		if i > 0:
			draw_line(prev, p, Color.GREEN, 2)

		prev = p

	# --- vertical markers (stock) ---
	if show_markers:
		for i in range(stock_ranges.size()):

			var entry = stock_ranges[i]
			var color = get_region_color(i, ranges_max)

			draw_vertical_marker(
				entry.value,
				entry.name,
				color,
				x_min,x_max,y_min,y_max,w,h
			)

	# --- horizontal markers (prices) ---
	for i in range(price_ranges.size()):

		var entry = price_ranges[i]
		var color = get_region_color(i, ranges_max)

		draw_horizontal_marker(
			entry.value,
			entry.name,
			color,
			x_min,x_max,y_min,y_max,w,h
		)


	# --- Axis Labels ---
	if font:

		# X axis label (bottom center)
		draw_string(
			font,
			Vector2(w * 0.5 - 40, h - 6),
			x_axis_label,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size + 2,
			Color.WHITE
		)

		# Y axis label (top-left)
		draw_string(
			font,
			Vector2(6, 14),
			y_axis_label,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size + 2,
			Color.WHITE
		)
	
	for trader in dynamic_prices:
		draw_marker(
			dynamic_prices[trader].stock,
			dynamic_prices[trader].price,
			trader.entity.display_name,
			Color.from_hsv(trader.get_instance_id() % 360 / 360., 0.5, 1, 0.8),
			6,
			x_min,x_max,y_min,y_max,w,h
		)
	
	if price_calculator.item:
		draw_marker(
			x_max-20,
			y_max,
			price_calculator.item.display_name,
			Color.WHITE,
			0,
			x_min,x_max,y_min,y_max,w,h
		)


func draw_marker(
	x_value: float,
	y_value: float,
	label: String,
	color: Color,
	radius: float,
	x_min: float,
	x_max: float,
	y_min: float,
	y_max: float,
	w: float,
	h: float
):

	if x_value < x_min or x_value > x_max:
		return


	var px = world_to_screen_x(x_value, x_min, x_max, w)
	var py = world_to_screen_y(y_value, y_min, y_max, h)



	draw_circle(Vector2(px,py), radius, color)

	if font:
		draw_string(
			font,
			Vector2(px + radius, py - radius).floor(),
			label,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size,
			color
		)
		draw_string_outline(
			font,
			Vector2(px + radius, py - radius).floor(),
			label,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size,
			1,
			color
		)

func draw_vertical_marker(
	x_value: float,
	label: String,
	color: Color,
	x_min: float,
	x_max: float,
	y_min: float,
	y_max: float,
	w: float,
	h: float
):
	if x_value < x_min or x_value > x_max:
		return

	# Only draw if the Y axis exists in the view
	if not (0 >= y_min and 0 <= y_max):
		return

	var px = world_to_screen_x(x_value, x_min, x_max, w)
	var axis_y = world_to_screen_y(0, y_min, y_max, h)

	# horizontal guide (BOTTOM SIDE ONLY)
	draw_line(
		Vector2(px, 0),
		Vector2(px, h),
		Color(color.r, color.g, color.b, 0.5),
		1
	)

	# tick on axis
	draw_line(
		Vector2(px, axis_y - 4),
		Vector2(px, axis_y + 4),
		color,
		3
	)

	# label
	var text_width = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	
	if font:
		draw_string(
			font,
			Vector2( px-text_width - 4, axis_y + font_size*2).floor(),
			label,
			HORIZONTAL_ALIGNMENT_LEFT,
			text_width,
			font_size,
			color
		)


func draw_horizontal_marker(
	y_value: float,
	label: String,
	color: Color,
	x_min: float,
	x_max: float,
	y_min: float,
	y_max: float,
	w: float,
	h: float
):
	if y_value < y_min or y_value > y_max:
		return

	# Only draw if the Y axis exists in the view
	if not (0 >= x_min and 0 <= x_max):
		return

	var py = world_to_screen_y(y_value, y_min, y_max, h)
	var axis_x = world_to_screen_x(0, x_min, x_max, w)

	# horizontal guide (LEFT SIDE ONLY)
	draw_line(
		Vector2(0, py),
		Vector2(axis_x, py),
		Color(color.r, color.g, color.b, 0.35),
		1
	)

	# tick on axis
	draw_line(
		Vector2(axis_x - 5, py),
		Vector2(axis_x + 5, py),
		color,
		2
	)

	# label
	if font:
		draw_string(
			font,
			Vector2(6, py - 4).floor(),
			label,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size,
			color
		)


func draw_region(
	x0: float,
	x1: float,
	color: Color,
	x_min: float,
	x_max: float,
	w: float,
	h: float
):
	color.a = 0.08
	if x1 <= x_min or x0 >= x_max:
		return

	var sx0 = world_to_screen_x(clamp(x0, x_min, x_max), x_min, x_max, w)
	var sx1 = world_to_screen_x(clamp(x1, x_min, x_max), x_min, x_max, w)

	draw_rect(
		Rect2(Vector2(sx0, 0), Vector2(sx1 - sx0, h)),
		color,
		true
	)
