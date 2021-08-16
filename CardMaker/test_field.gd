extends Node2D

#For now, this is just recycling a bunch of code from the test_card_viewer
#to load the player's cards. Eventually it'll be changed to load their deck

const base_card_template = preload("res://card_templates/basecardtemplate.tscn")
var content = null
const test_card = "user://test_cards/test_card.save"

signal player_life_changed
signal opp_life_changed
signal test_creature_life_changed
signal player_mana_changed

var target = null
signal target_chosen

func load_from_file():
	var file = File.new()
	if file.file_exists(test_card):
		file.open(test_card, File.READ)
		content = str2var(file.get_as_text())
		file.close()

# Called when the node enters the scene tree for the first time.
func _ready():
	load_from_file()
	var card = base_card_template.instance()
	card.slot_five_dict = content["export_list_of_dicts"][0]
	card.slot_six_dict = content["export_list_of_dicts"][1]
	card.sprite_path_list = content["export_sprite_path_list"]
	card.type = content["type"]
	card.list_of_dicts = [card.slot_five_dict, card.slot_six_dict]
	add_child(card)
	card.update()
	card.scale = Vector2(.5, .5)
	card.position = $hand_one.position
	
	for node in get_tree().get_nodes_in_group("targeting_buttons"):
		node.hide()


func take_damage(amount):
	### Read up more on match statements to determine if they'll be useful for
	#handling things like this when they grow to have large numbers of possible
	#targets. (They probably will; the runtime benefit won't be huge, but the code
	#will be much cleaner)
	if target == "player":
		###STANDARDIZE THESE; HAVE EVERYTHING HAVE SET_HEALTH, HEALTH_CHANGED ETC
		$player_placeholder.set_health(amount)
		emit_signal("player_life_changed")
	elif target == "opponent":
		$opp_placeholder.set_health(amount)
		emit_signal("opp_life_changed")
	elif target == "test_creature":
		$test_creature.set_health(amount)
		emit_signal("test_creature_life_changed")

func choose_target(targets):
	#Works, just need to add more targeting scenarios as they come up
	$guidance.text = "Choose a target"
	if targets == "opponent_all":
		$opp_placeholder/targeting_button.show()
		$test_creature/test_creature_button.show()
		yield(self, "target_chosen")

#We were able to eliminate the need for separate functions with and without a
#target argument; keep your eye out for how we can eliminate the effect_int
#argument as well (there's assuredly some analogous way to get it to work with a
#global variable or something).
###Eod 8/12 decided to just set modified_effect_int to null in the on_card_cast
#function; we'll have to see if this works down the line. It seems to me that it should,
#since this basically means that this function gets passed a nothing argument if
#it doesn't need an integer.
func process_effect(effect, effect_int):
	if effect == "damage":
		take_damage(effect_int * -1)

func _on_card_cast(received_slot_five_dict, received_slot_six_dict, cost):
	#All works (honoo omoi) but is hideous as fuck, there's gotta be a better way here;
	#one option might be to abstract what's below into another function and call it on
	#each dictionary, though as we've observed before, slot five has its own thing since
	#it determines where the card goes at the end.
	var modified_effect_int = null
	if "targets" in received_slot_five_dict.keys():
		yield(choose_target(received_slot_five_dict["targets"]), "completed")
	if "effect_int" in received_slot_five_dict.keys() and "ue" in received_slot_six_dict.values():
		modified_effect_int = received_slot_five_dict["effect_int"] + 1
	else:
		modified_effect_int = received_slot_five_dict["effect_int"]
	process_effect(received_slot_five_dict["effect"], modified_effect_int)
	target = null
	$player_placeholder.set_mana(cost * -1 )
	emit_signal("player_mana_changed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_targeting_button_pressed():
	target = "opponent"
	emit_signal("target_chosen")


func _on_test_creature_button_pressed():
	target = "test_creature"
	emit_signal("target_chosen")
