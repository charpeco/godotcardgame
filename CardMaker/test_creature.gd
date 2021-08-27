extends Label


var health = 3 setget set_health
var power = 2 setget set_power
var min_power = 0 setget set_min_power
signal health_changed
signal dead
signal power_changed

func set_health(value):
	health += value
	emit_signal("health_changed")
	if health < 1:
		emit_signal("dead")

func set_power(value):
	power += value
	clamp(power, min_power, 999)
	emit_signal("power_changed")

func set_min_power(value):
	min_power += value

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_test_creature_dead():
	self.hide()
