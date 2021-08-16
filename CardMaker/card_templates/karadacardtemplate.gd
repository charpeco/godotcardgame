extends "res://card_templates/basecardtemplate.gd"


var romaji_text = null
var creature_type = null
var static_ability = null
var power = null
var toughness = null

var haste = false
var deathtouch = false
var first_strike = false
var ward = false
var unblockable = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#REMEMBER--somehow, the on_cast_button_pressed function is there, it's just
#inheriting from the base template, apparently, despite needing to create a new
#button node on this one.
