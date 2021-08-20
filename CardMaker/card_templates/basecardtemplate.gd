extends Node2D

var romaji_name = ""
var type = ""
var kanji_name = ""
var cost = 0
#var effect_text = ""
var effect_int = 0
var suit = null
var row = null
var serial_id = ""

var sprite_path_list = []

var slot_five_dict = {}
var slot_six_dict = {}

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
var list_of_dicts = [slot_five_dict, slot_six_dict]

#There's definitely some no-no kinda stuff going on here with regard to DRY; the root
#of the problem is that we don't know enough about file manipulation to work with
#the existing data structures more efficiently. But, for now, this works as a way
#to save everything we need so that we can unpack it later and reassign everything
var export_data = {"export_list_of_dicts" : list_of_dicts,
					"export_sprite_path_list" : sprite_path_list,
					"type" : ""
					}

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass

func romaji_name_update():
	#Another nail in the coffin for iterating over the list_of_dicts--this'll
	#get stuff backwards no matter what because it'll either put in slot six text
	#after slot five or (if we iterate over it backwards) it'll put in slots 1/2,
	#3/4 last. IT DOES OCCUR TO ME, HOWEVER, that once we have all the slots coded
	#we should look into rearranging the order of the list of dicts to permit
	#iteration. Ie, if we have the list go 1/2/3/4/6/5, then it should put things in
	#in order. I still don't know if that'll ever allow cost_update to work though.
	for dict in list_of_dicts:
		if dict.empty() != true:
			$romaji_name_label.text += dict["identifier"]

func cost_update():
	if slot_six_dict.empty() == true:
		cost += slot_five_dict["cost"]
	else:
		cost += (slot_five_dict["cost"] * slot_six_dict["cost"])
	$cost_label.text = str(cost)

func effect_text_cleanup(effect_text):
	effect_text = effect_text.replace("  ", " ")
	effect_text = effect_text.lstrip(" ")
	effect_text = effect_text.rstrip(" ")
	effect_text[0] = effect_text[0].to_upper()
	effect_text += "."
	return effect_text

func effect_text_update():
	var effect_text = ""
	var triggered_effects_text = "\n"
	var activated_abilities_text = "\n"
	var slot_five_int
	###IT OCCURS TO ME THAT WE CAN REFACTOR THIS REPETITIVE FUNCTION TO HAVE CERTAIN
	###CHECKS FOR THE PERTINENT MODIFIERS; HAVE THINGS LIKE THE UE CHECK ONLY HAPPEN IF
	###AN ARGUMENT IS PASSED TELLING IT TO PERFORM THAT CHECK.
	#
	###SLOT 5 WORK BEGINS HERE
	###
	###
	var slot_five_prep_string = type_starters[type]
	#Start by cordoning off any activated abilities or triggered effects where they belong. The triggered
	#ability check also removes "{effect}" from the starting string since it's
	#no longer necessary
	if "effect_int" in slot_five_dict.keys():
		if slot_six_dict.empty() == true:
			slot_five_int = slot_five_dict["effect_int"]
		elif slot_six_dict["symbol_name"] != "ue":
			slot_five_int = slot_five_dict["effect_int"]
		elif slot_six_dict["symbol_name"] == "ue":
			slot_five_int = slot_five_dict["effect_int"] + 1
	if "activated_ability_cost" in slot_five_dict.keys():
		slot_five_prep_string = slot_five_prep_string.replace("{effect}", "")
		activated_abilities_text += (str(slot_five_dict["activated_ability_cost"]) 
									+ ": " 
									+ effect_texts_dict[slot_five_dict["effect"]])
		if "targets" in activated_abilities_text:
			activated_abilities_text = activated_abilities_text.format({"targets" : targets_dict[self.slot_five_dict["targets"]]})
		if "effect_int" in activated_abilities_text:
			activated_abilities_text = activated_abilities_text.format({"effect_int" : str(slot_five_int)})
	if "ability_trigger" in slot_five_dict.keys():
		slot_five_prep_string = slot_five_prep_string.replace("{effect}", "")
		triggered_effects_text += (effect_triggers_dict[self.slot_five_dict["ability_trigger"]]
									 + effect_texts_dict[self.slot_five_dict["effect"]])
		if "targets" in triggered_effects_text:
			triggered_effects_text = triggered_effects_text.format({"targets" : targets_dict[self.slot_five_dict["targets"]]})
		if "effect_int" in triggered_effects_text:
			triggered_effects_text = triggered_effects_text.format({"effect_int" : str(slot_five_int)})
	if "effect" in slot_five_dict.keys() and not "ability_trigger" in slot_five_dict.keys():
		slot_five_prep_string = slot_five_prep_string.format({"effect" : effect_texts_dict[slot_five_dict["effect"]]})
	if "identifier" in slot_five_dict.keys():
		slot_five_prep_string = slot_five_prep_string.format({"identifier" : slot_five_dict["identifier"]})
	if "effect_int" in slot_five_dict.keys():
		slot_five_prep_string = slot_five_prep_string.format({"effect_int" : str(slot_five_int)})
	if "targets" in slot_five_dict.keys():
		slot_five_prep_string = slot_five_prep_string.format({"targets" : targets_dict[slot_five_dict["targets"]]})
	effect_text += slot_five_prep_string
	### SLOT 6 WORK BEGINS HERE.
	###
	###
	if slot_six_dict.empty() == false:
		var slot_six_prep_string = ""
		if slot_six_dict["symbol_name"] == "tomo" or slot_six_dict["symbol_name"] == "teki":
			if "activated_ability_cost" in slot_six_dict.keys():
				slot_six_prep_string = slot_six_prep_string.replace("{effect}", "")
				activated_abilities_text += (str(slot_six_dict["activated_ability_cost"]) 
											+ ": " 
											+ effect_texts_dict[slot_six_dict["effect"]])
			if "targets" in activated_abilities_text:
				activated_abilities_text = activated_abilities_text.format({"targets" : targets_dict[self.slot_six_dict["targets"]]})
		if "effect_int" in activated_abilities_text:
			activated_abilities_text = activated_abilities_text.format({"effect_int" : str(self.slot_five_dict["effect_int"])})
			if "ability_trigger" in slot_six_dict.keys():
				var slot_six_triggered_text = ""
				slot_six_prep_string = slot_six_prep_string.replace("{effect}", "")
				slot_six_triggered_text += (effect_triggers_dict[self.slot_six_dict["ability_trigger"]]
								 + effect_texts_dict[self.slot_six_dict["effect"]])
				if "effect_int" in slot_six_triggered_text:
					slot_six_triggered_text = slot_six_triggered_text.format({"effect_int" : str(self.slot_six_dict["effect_int"])})
				triggered_effects_text += slot_six_triggered_text
			if "effect" in slot_six_dict.keys() and not "ability_trigger" in slot_six_dict.keys():
				slot_six_prep_string += effect_texts_dict[slot_six_dict["effect"]]
			if "effect_int" in slot_six_dict.keys():
				slot_six_prep_string = slot_six_prep_string.format({"effect_int" : str(slot_six_dict["effect_int"])})
			if "targets" in slot_six_dict.keys():
				slot_six_prep_string = slot_six_prep_string.format({"targets" : targets_dict[slot_six_dict["targets"]]})
		effect_text += slot_six_prep_string
	effect_text = effect_text_cleanup(effect_text)
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
#	There's certainly more fussing that can be done over scaling and positioning,
#	but for now, this works.
	var height = $frame.texture.get_height()
	var width = $frame.texture.get_width()
	var symbol_sprites_iterable = []
	for child in self.get_children():
		if child.is_in_group("symbol_sprites"):
			symbol_sprites_iterable.append(child)
	var number_of_sprites = len(sprite_path_list)
	var first_position = .5 - (.05 * number_of_sprites)
	for index in range(0, number_of_sprites):
		symbol_sprites_iterable[index].texture = load(sprite_path_list[index])
		symbol_sprites_iterable[index].scale = Vector2(.5, .5)
		symbol_sprites_iterable[index].position.x = width * (first_position + (index * .20))
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
