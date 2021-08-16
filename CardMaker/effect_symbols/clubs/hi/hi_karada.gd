extends "res://effect_symbols/clubs/hi/hi.gd"

var romaji_text = "Goblin"
var creature_type = "Goblin"
var static_ability = "haste"
var effect_text = "Summon a Goblin"
var power = 1
var toughness = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func cast():
	print("Summon a goblin")
