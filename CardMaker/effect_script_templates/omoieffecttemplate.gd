extends Node2D

var data_dict = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func cast():
	#\/ This or something like it is the plan for now (7/12); it'll probably get
	#more complicated when we start mucking around with modifiers, but the idea being
	#that this template knows how to do all the basic functions, and it just needs to grab/
	#be fed the data from modifiers as necessary. 
	if data_dict["symbol_name"] == "hi":
		var prep_string = "Deal {effect int} damage to a target."
		var actual_string = prep_string.format({"effect int": data_dict[str("effect_int")]})
		print(actual_string)
	elif data_dict["symbol_name"] == "kaze":
		var prep_string = "Draw {effect int} cards, then discard {effect int} cards."
		var actual_string = prep_string.format({"effect int": data_dict[str("effect_int")]})
		print(actual_string)
