extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.text = "Power: " + str(get_parent().power)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_test_creature_power_changed():
	self.text = "Power: " + str(get_parent().power)
