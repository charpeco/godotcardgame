extends Node2D

var data_dict = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func cast():
	var prep_string = "Summon a {creature}"
	var actual_string = prep_string.format({"creature": data_dict["creature_type"]})
	print(actual_string)
