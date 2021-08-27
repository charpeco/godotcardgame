extends Label


var mana = 100


# Called when the node enters the scene tree for the first time.
func _ready():
	self.text = "Mana:" + str(get_parent().mana)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass





func _on_player_placeholder_mana_changed():
	self.text = "Mana:" + str(get_parent().mana)
