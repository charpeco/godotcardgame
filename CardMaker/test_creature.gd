extends Label


var health = 3 setget set_health
signal dead

func set_health(value):
	health += value
	if health < 1:
		emit_signal("dead")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_test_creature_dead():
	self.hide()
