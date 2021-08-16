extends Node2D

var data_dict = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func cast():
	#Occurs to me we'll need to be able to handle "a / an" for card text
	var prep_string = "Create a {artifact}"
	var actual_string = prep_string.format({"artifact": data_dict["artifact_type"]})
	print(actual_string)
