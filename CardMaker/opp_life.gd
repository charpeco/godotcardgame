extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.text = "Life:" + str(get_parent().health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass






func _on_test_field_opp_life_changed():
	self.text = "Life" + str(get_parent().health)
