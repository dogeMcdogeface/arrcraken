extends Control

@onready var graph = $HSplitContainer/PriceCurveGraph
@onready var controls = $HSplitContainer/GridContainer


func _ready():
	_generate_controls()


func _generate_controls():

	for c in controls.get_children():
		c.queue_free()

	if !graph.price_calculator:
		return

	var in_algorithm_group := false

	for prop in graph.price_calculator.get_property_list():
		# detect group headers
		if prop.usage == PROPERTY_USAGE_GROUP:
			in_algorithm_group = (prop.name == "Price Ranges") || (prop.name == "Stock Ranges") || (prop.name == "Factors")
			continue

		if !in_algorithm_group:
			continue

		# only script variables
		if !(prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
			continue

		# only numbers
		if prop.type not in [TYPE_FLOAT, TYPE_INT]:
			continue

		var var_name = prop.name

		# Label
		var label := Label.new()
		label.text = var_name
		controls.add_child(label)

		# SpinBox
		var spin := SpinBox.new()
		spin.allow_greater = true
		spin.allow_lesser = true
		spin.name = var_name
		spin.min_value = -100000
		spin.max_value = 100000
		spin.step = 0.01
		spin.custom_arrow_step = 1

		spin.value = graph.price_calculator.get(var_name)
		spin.value_changed.connect(_on_spinbox_changed.bind(var_name))

		controls.add_child(spin)


func _on_spinbox_changed(value: float, var_name: String):
	graph.price_calculator.set(var_name, value)
