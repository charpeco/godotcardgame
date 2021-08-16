#Presently useless since we've decided just to maintain the separate template
#scripts, but keeping it in case we can thread the needle in the cardmaker's
#inheritance structure in a way that allows us to use this, and to keep a running list
#of everything that an effect node could conceivably have

extends Node

#Not presently in use, use the one with the string keys and pray to God you don't
#have to change it again. Alternatively, get better at computer science and figure out
#a less fragile system.
var data_dict_variables = {symbol_name = null,
					suit = null,
					row = null,
					cost = null,
					"karada" : {
								creature_type = null, 
								static_ability = null,
								triggered_ability = null,
								ability_trigger = null,
								power = null,
								toughness = null,
								effect_int = null,
								effect_text = null,
								},
					"mono" : {
								artifact_type = null,
								triggered_ability = null,
								ability_trigger = null,
								activated_ability = null,
								activated_ability_cost = 0,
								effect_int = null,
								effect_text = null,
								},
					"omoi" : {
								effect_int = null,
								effect_text = null,
								},
					"ji" : {}
					}

var data_dict_strings = {
						"symbol_name" : "",
						"suit" : "",
						"row" : 0,
						"cost" : 0,
						"karada" : {
							"effect_text" : "",
							"effect_int" : "",
							"creature_type" : "", 
							"static_ability" : "",
							"triggered_ability" : null,
							"ability_trigger" : null,
							"power" : 0,
							"toughness" : 0,
							},
						"mono" : {
						"effect_text" : "",
						"effect_int" : 0,
						"artifact_type" : "",
						"activated_ability" : null,
						"activated_ability_cost" : 0,
						"triggered_ability" : null,
						"ability_trigger" : null,
							},
						"omoi" : {
							"effect_text" : "",
							"effect_int" : 2
							},
						"ji" : {}
						}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
