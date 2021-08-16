extends Label


var health = 20 setget set_health
var mana = 100 setget set_mana

func set_health(value):
	health += value

func set_mana(value):
	mana += value

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
