extends Node2D

var romaji_name = ""
var type = ""
var cost = 0
var suit = null
var row = null
var serial_id = ""

var sprite_path_list = []

var slot_five_dict = {}
var slot_six_dict = {}
var slot_three_four_dict = {}
var slot_one_two_dict = {}

const type_starters = {"karada" : "Summon a {identifier} {effect}",
						"mono" : "Create a {identifier}",
						"omoi" : "{effect}"}

const effect_texts_dict = {"haste" : " that can attack the turn you summon it ",
						"panic" : " {effect_int} creatures can't block this turn ",
						"ransack" : " draw {effect_int} cards, then discard {effect_int} cards ",
						"damage" : " deal {effect_int} damage to {targets} ",
						"ferocity" : " with {effect_int} power that can't be reduced",
						"depower" : " reduce {targets} 's power by {effect_int}"}

const effect_triggers_dict = {"any_damage_player" : "Whenever a creature deals damage to your opponent, ",
							"self_damage_player" : "Whenever this deals damage to your opponent, ",
							"on_block" : "Whenever this blocks, ",
							"player_turn_start" : "At the beginning of your turn, "}

const targets_dict = {"opponent_all" : "your opponent or one of their creatures",
						"opponent_creatures" : "one of your opponent's creatures",
						"blocked_creature" : "the creature it blocked"}


signal card_cast

#Remains to be seen if there'll ever be a case where we can just iterate over
#all the dictionaries or if there will always be enough exceptions to processing
#card data that we'll need a more nuanced function.
###Be open to the idea of having more than one of these as well--there might be an
#arrangement that makes sense for iterating through romaji names that is not
#the arrangement that makes sense for generating effect text.

#There's definitely some no-no kinda stuff going on here with regard to DRY.
#But, for now, this works as a way to save everything we need so that we can 
#unpack it later and reassign everything
var export_data = {"export_list_of_dicts" : [slot_five_dict, slot_six_dict, slot_three_four_dict, slot_one_two_dict],
					"export_sprite_path_list" : sprite_path_list,
					"type" : ""
					}

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass

func romaji_name_update():
	if slot_one_two_dict.empty() == false:
		$romaji_name_label.text += slot_one_two_dict["identifier"] + " "
	if slot_three_four_dict.empty() == false:
		$romaji_name_label.text += slot_three_four_dict["identifier"] + " "
	if slot_six_dict.empty() == false:
		$romaji_name_label.text += slot_six_dict["identifier"] + " "
	$romaji_name_label.text += slot_five_dict["identifier"] + " "

func cost_update():
	if slot_six_dict.empty() == true:
		cost += slot_five_dict["cost"]
	else:
		cost += (slot_five_dict["cost"] * slot_six_dict["cost"])
	if slot_three_four_dict.empty() != true:
		cost += slot_three_four_dict["cost"]
	if slot_one_two_dict.empty() != true:
		cost += slot_one_two_dict["cost"]
	$cost_label.text = str(cost)

#Presently fails to capitalize second sentences of effect_text
func effect_text_cleanup(effect_text):
	if effect_text.empty() == false:
		effect_text = effect_text.replace("  ", " ")
		effect_text = effect_text.lstrip(" ")
		effect_text = effect_text.rstrip(" ")
		effect_text[0] = effect_text[0].to_upper()
		effect_text += "."
		return effect_text


func effect_text_helper(effect_dict):
	var prep_string = ""
	var activated_abilities_string = ""
	var triggered_effects_string = ""
	var effect_int = null
	if "effect_int" in effect_dict.keys():
		effect_int = effect_dict["effect_int"]
	if effect_dict == slot_five_dict:
		prep_string += type_starters[type]
		if "effect_int" in slot_five_dict.keys():
			if slot_six_dict.empty() != true:
				if slot_six_dict["symbol_name"] == "ue":
					effect_int += 1
	else:
		prep_string += "{effect}"
	if "activated_ability_cost" in effect_dict.keys():
		prep_string = prep_string.replace("{effect}", "")
		activated_abilities_string += (str(effect_dict["activated_ability_cost"]) 
									+ ": " 
									+ effect_texts_dict[effect_dict["effect"]])
		if "targets" in activated_abilities_string:
			#Watch out for these self.thing declarations now that they're pulling a variable
			activated_abilities_string = activated_abilities_string.format({"targets" : targets_dict[effect_dict["targets"]]})
		if "effect_int" in activated_abilities_string:
			activated_abilities_string = activated_abilities_string.format({"effect_int" : str(effect_int)})
	if "ability_trigger" in effect_dict.keys():
		prep_string = prep_string.replace("{effect}", "")
		triggered_effects_string += (effect_triggers_dict[effect_dict["ability_trigger"]]
									 + effect_texts_dict[effect_dict["effect"]])
		if "targets" in triggered_effects_string:
			triggered_effects_string = triggered_effects_string.format({"targets" : targets_dict[effect_dict["targets"]]})
		if "effect_int" in triggered_effects_string:
			triggered_effects_string = triggered_effects_string.format({"effect_int" : str(effect_int)})
	if "effect" in effect_dict.keys() and not "ability_trigger" in effect_dict.keys():
		prep_string = prep_string.format({"effect" : effect_texts_dict[effect_dict["effect"]]})
	if "identifier" in effect_dict.keys():
		prep_string = prep_string.format({"identifier" : effect_dict["identifier"]})
	if "effect_int" in effect_dict.keys():
		prep_string = prep_string.format({"effect_int" : str(effect_int)})
	if "targets" in effect_dict.keys():
		prep_string = prep_string.format({"targets" : targets_dict[effect_dict["targets"]]})
	effect_text_cleanup(prep_string)
	return [prep_string, activated_abilities_string, triggered_effects_string]


func effect_text_update():
	var effect_text = ""
	var activated_abilities_text = "\n"
	var triggered_effects_text = "\n"
	###SLOT 5 WORK BEGINS HERE
	###
	###
	var slot_five_text = effect_text_helper(slot_five_dict)
	effect_text += slot_five_text[0]
	activated_abilities_text += slot_five_text[1]
	triggered_effects_text += slot_five_text[2]
#	effect_text = effect_text_cleanup(effect_text)
	### SLOT 6 WORK BEGINS HERE.
	###
	###
	if slot_six_dict.empty() == false:
		###TOMO/TEKI WORK BEGINS HERE
		#
		#
		if slot_six_dict["symbol_name"] == "tomo" or slot_six_dict["symbol_name"] == "teki":
			var slot_six_text = effect_text_helper(slot_six_dict)
			effect_text += slot_six_text[0]
			activated_abilities_text += slot_six_text[1]
			triggered_effects_text += slot_six_text[2]
#	effect_text = effect_text_cleanup(effect_text)
	### SLOT 3/4 WORK BEGINS HERE.
	###
	###
	if slot_three_four_dict.empty() == false:
		###TOMO/TEKI WORK BEGINS HERE
		#
		#
		if slot_three_four_dict["symbol_name"] == "mon":
			var slot_three_four_text = effect_text_helper(slot_three_four_dict)
			effect_text += slot_three_four_text[0]
			activated_abilities_text += slot_three_four_text[1]
			triggered_effects_text += slot_three_four_text[2]
#	effect_text = effect_text_cleanup(effect_text)
	#Add the triggered effects text if necessary and repeat. The check is for
	#length != 1 because of the "\n" in the initial triggered effects string (I guess
	#it doesn't count the escaping forward slash).
	if triggered_effects_text.length() != 1:
		effect_text += triggered_effects_text
		effect_text = effect_text_cleanup(effect_text)
	if activated_abilities_text.length() != 1:
		effect_text += activated_abilities_text
		effect_text = effect_text_cleanup(effect_text)
	$effect_text_label.text = effect_text

func symbol_sprite_update():
#	We'll probably need to convert the if else below to an if elif else for
#	7-symbol cards, but other than that this is looking good.
	var height = $frame.texture.get_height()
	var width = $frame.texture.get_width()
	var symbol_sprites_iterable = []
	for child in self.get_children():
		if child.is_in_group("symbol_sprites"):
			symbol_sprites_iterable.append(child)
	var number_of_sprites = len(sprite_path_list)
	var first_position = .45 - (.05 * number_of_sprites)
	for index in range(0, number_of_sprites):
		symbol_sprites_iterable[index].texture = load(sprite_path_list[index])
		if number_of_sprites < 5:
			symbol_sprites_iterable[index].scale = Vector2(.5, .5)
			symbol_sprites_iterable[index].position.x = width * (first_position + (index * .2))
			symbol_sprites_iterable[index].position.y = height * .35
		else:
			symbol_sprites_iterable[index].scale = Vector2(.4, .4)
			symbol_sprites_iterable[index].position.x = width * (first_position + (index * .15))
			symbol_sprites_iterable[index].position.y = height * .35

func update():
	romaji_name_update()
	cost_update()
	effect_text_update()
	symbol_sprite_update()
	if get_parent().name == "test_field":
		self.connect("card_cast", get_parent(), "_on_card_cast")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_cast_button_pressed():
	#The simplest way we've thought of so far to pass modular signals up the chain;
	#when implemented, the "test" variable will be something like the "effect" module
	#in the effect dictionary, and then the test field (eventually, the real gameplay zone)
	#will have the ability to convert the argument passed into the function that needs to
	#be executed. It obviously gets a lot more complicated when we start handling effect_ints
	#and stuff like that, but we do now have a way for the cards to make things happen in the 
	#test field.
	#Works with honoo omoi to decrease the player's health by two, but we're stilld dealing with
	#the variable argument problem.
	emit_signal("card_cast", slot_five_dict, slot_six_dict, cost)
