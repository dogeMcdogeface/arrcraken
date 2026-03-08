extends Node
class_name BehaviourManager

var buckets := {}
func register_behaviour(behaviour: Behaviour):
	var interval = behaviour.update_interval
	if interval < 0:
		return
	if !buckets.has(interval):
		buckets[interval] = {"behaviours":[] as Array[Behaviour], "timer": WorldTimer.new(interval)}

	buckets[interval].behaviours.append(behaviour)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.BehaviourManager = self
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for bucket in buckets:
		if buckets[bucket].timer.tick():
			#print("updating ", bucket)
			for behaviour:Behaviour in buckets[bucket].behaviours:
				behaviour.process_tick(buckets[bucket].timer)
	pass
