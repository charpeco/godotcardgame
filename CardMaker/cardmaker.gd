extends Node2D

var sprite_path = null
const card_save_path = "user://"

const sqlite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db = null
var db_name = "res://sqlite_data/database.db"

signal guidance_changed

#This gets filled by looping in _ready.
var symbol_sprite_dict = {}

const base_card_template = preload("res://card_templates/basecardtemplate.tscn")

const effect_dict = {
						"hi" : {
								"slot_five" : {
									"symbol_name" : "hi",
									"suit" : "clubs",
									"row" : 1,
									"cost" : 10
									},
								"karada" : {
									"identifier" : "Goblin", 
									"effect" : "haste",
									"power" : 1,
									"toughness" : 1,
									},
								"mono" : {
									"identifier" : "Goblin Totem",
									"effect" : "panic",
									"activated_ability_cost" : 15,
									"effect_int" : 1,
										},
								"omoi" : {
									"effect" : "panic",
									"identifier" : "Panic",
									"effect_int" : 2
									},
								"ji" : {},
								"slot_six" : 
									{
										"tomo" : "kaze"
										}
								},
						"kaze" : {
								"slot_five" : {
									"symbol_name" : "kaze",
									"suit" : "spades",
									"row" : 1,
									"cost" : 10
								},
								"karada" : {
									"identifier" : "Warhound", 
									"effect" : "ransack",
									"ability_trigger" : "self_damage_player",
									"power" : 1,
									"toughness" : 1,
									"effect_int" : 1,
								},
								"mono" : {
									"identifier" : "Warhound Totem",
									"effect" : "ransack",
									"ability_trigger" : "any_damage_player",
									"effect_int" : 1,
								},
								"omoi" : {
										"identifier" : "Ransack",
										"effect" : "ransack",
										"effect_int" : 2,
										},
								"ji" : {},
								"slot_six" : 
									{
										"tomo" : "hi"
										}
								},
						"honoo" : {
								"slot_five" : {
									"symbol_name" : "honoo",
									"suit" : "clubs",
									"row" : 2,
									"cost" : 15
									},
								"karada" : {
									"identifier" : "Placeholder", 
									"effect" : "ferocity",
									"power" : 1,
									"toughness" : 1,
									"effect_int" : 2
									},
								"mono" : {
									"identifier" : "Placeholder",
									"effect" : "damage",
									"activated_ability_cost" : 10,
									"effect_int" : 1,
									"targets" : "opponent_all"
										},
								"omoi" : {
									"effect" : "damage",
									"identifier" : "Damage",
									"effect_int" : 2,
									"targets" : "opponent_all"
									},
								"ji" : {},
								"slot_six" : 
									{
										"tomo" : "kaminari",
										"teki" : "yuki"
										}
								},
						"yuki" : {
								"slot_five" : {
									"symbol_name" : "yuki",
									"suit" : "hearts",
									"row" : 2,
									"cost" : 15
									},
								"karada" : {
									"identifier" : "Frostkin", 
									"effect" : "depower",
									"power" : 1,
									"toughness" : 3,
									"effect_int" : 1,
									"ability_trigger" : "on_block",
									"targets" : "blocked_creature"
									},
								"mono" : {
									"identifier" : "Frostkin totem",
									"effect" : "depower",
									"effect_int" : 1,
									"targets" : "opponent_creatures",
									"ability_trigger" : "player_turn_start"
										},
								"omoi" : {
									"effect" : "depower",
									"identifier" : "Depower",
									"effect_int" : 2,
									"targets" : "opponent_creatures"
									},
								"ji" : {},
								"slot_six" : 
									{
										"tomo" : "chi",
										"teki" : "honoo"
										}
								}
							}

const slot_six_mod_dict = {
						"ue" : {
								"symbol_name" : "ue",
								"cost" : 1.5,
								#Occurs to me that one modifier name for each
								#type might be too narrow; consider adding different
								#adjectives for different types.
								"identifier" : "Enhanced"
								},
						"tomo" : {
								"symbol_name" : "tomo",
								"cost" : 2,
								"identifier" : "-Allied"
								},
						"teki" : {
								"symbol_name" : "teki",
								"cost" : 2.5,
								"identifier" : "-Allied"
									}
						}

const slot_four_mod_dict = {
							"mon" : {
									"identifier" : "Interval-",
									"symbol_name" : "mon",
									"karada" :
										{
										"ability_trigger" : "self_damage_player"
									},
									"mono" :
										{
											"ability_trigger" : "player_turn_start"
										}
							}
						}


#It probably seems silly to have the suit reference itself as "suit," but
#it makes some of the helper functions below cleaner.
const enemy_ally_suit_dict = {
								"clubs" : {
											"suit" : "clubs",
											"ally" : "spades",
											"enemy" : "hearts"
								},
								"hearts" : {
											"suit" : "hearts",
											"ally" : "diamonds",
											"enemy" : "spades"
								},
								"spades" : {
											"suit" : "spades",
											"ally" : "clubs",
											"enemy" : "diamonds"
								},
								"diamonds" : {
											"suit" : "diamonds",
											"ally" : "hearts",
											"enemy" : "clubs"
								},
								}

#All the following through valid_slot_six_modifiers are upkeep and hints
#for the cardmaker itself and never actually get put on a card.
var selected_symbols_list = [null, null, null, null, null, null]
var selected_type = null
const button_list = ["chosen_symbols/1", "chosen_symbols/2",
					"chosen_symbols/3", "chosen_symbols/4",
					"chosen_symbols/5", "chosen_symbols/6",
					"chosen_symbols/7"]
const button_text = ["Effect", "Modifier", "Effect", "Modifier", "Effect", "Modifier", "Type"]
var current_symbol = null
#This dictionary determines what slot 6 mods should be permitted for a given slot 5
#effect
const valid_slot_six_modifiers = {"hi" : {
							"karada" : ["tomo"],
							"mono" : ["tomo", "ue"],
							"omoi" : ["tomo", "ue"]
							},
						"kaze" : {
							"karada" : ["tomo", "ue"],
							"mono" : ["tomo", "ue"],
							"omoi" : ["tomo", "ue"]
							},
						"yuki" : {
							"karada" : ["tomo", "ue", "teki"],
							"mono" : ["tomo", "ue", "teki"],
							"omoi" : ["tomo", "ue", "teki"]
							},
						"honoo" : {
							"karada" : ["tomo", "ue", "teki"],
							"mono" : ["tomo", "ue", "teki"],
							"omoi" : ["tomo", "ue", "teki"]
							}
						}

#This dictionary determines which slot 2 and 4 modifiers can be chosen based on
#card type. ***Implemented in chosen_symbol_button_pressed but not in modifier_button_pressed
#as of 8/25***
const valid_slot_four_modifiers = {"karada" : ["mon"],
									"mono" : ["mon"],
									"omoi" : []}

#This dictionary determines which slot 1 and 3 effects can be chosen based on
#slot 2 and 4 modifier.
const valid_slot_three_effects = {"mon" : ["suit", "ally"]
									}


#Helper function for _ready; connects buttons to function by group, and sets
#up what data those buttons pass when clicked. Also contains the shortcut to
#construct the symbol_sprite_dict--remember, if anything screwy ever starts happening
#with the symbol sprites, you can just manually code the name : sprite path pairs.
func button_group_connector(group, function):
	for button in get_tree().get_nodes_in_group(group):
		button.connect("pressed", self, function, [button])
		var sprite_dict_key = button.name
		var sprite_dict_value = str(button.texture_normal.get_load_path())
		symbol_sprite_dict[sprite_dict_key] = load(sprite_dict_value)
		#Presently hiding all buttons on initiliazation, this is where to turn
		#them back on if that's what we end up wanting
		button.visible = false

# Called when the node enters the scene tree for the first time.
# Creates a signal for each group of buttons that allows that button to pass itself
# to the relevant function. For now (and likely forever?) this is so the button's name can be used
# to update the cardmaker's UI and to prep the selected symbols list.
# Also populates the symbol sprites dictionary from those buttons and populates the
# symbol scenes dictionary from the symbols child node. Note that these are loaded from the
# button's texture--it seemed like a good way to avoid loading the same image multiple times,
# but it might do something screwy down the line.
# Initializes SQLite variables
func _ready():
	button_group_connector("effect_symbols", "_effect_button_pressed")
	button_group_connector("modifier_symbols", "_modifier_button_pressed")
	button_group_connector("type_symbols", "_type_button_pressed")
	
	for button in get_tree().get_nodes_in_group("chosen_symbol_buttons"):
		button.connect("pressed", self, "_chosen_symbol_button_pressed", [button])
	
	db = sqlite.new()
	db.path = db_name

func _effect_button_pressed(button):
	if current_symbol:
		get_node(button_list[current_symbol - 1]).text = ""
		get_node(button_list[current_symbol - 1]).icon = symbol_sprite_dict[button.name]
		selected_symbols_list[current_symbol - 1] = button.name
	#The following ensures that the player can't create invalid slot 5/6 pairs; use it
	#as a template (in reverse, essentially) for slots 1-4
	if (current_symbol == 5 and
		selected_type != null and
		not selected_symbols_list[5] in valid_slot_six_modifiers[selected_symbols_list[4]][selected_type]):
			selected_symbols_list[5] = null
			get_node("chosen_symbols/6").icon = null
			get_node("chosen_symbols/6").text = "Modifier"

func _modifier_button_pressed(button):
	if current_symbol:
		get_node(button_list[current_symbol - 1]).text = ""
		get_node(button_list[current_symbol - 1]).icon = symbol_sprite_dict[button.name]
		selected_symbols_list[current_symbol - 1] = button.name

func _type_button_pressed(button):
	if current_symbol:
		get_node(button_list[current_symbol - 1]).text = ""
		get_node(button_list[current_symbol - 1]).icon = symbol_sprite_dict[button.name]
		selected_type = button.name

#Helper function for chosen_symbol_button_pressed: feed it the booleans so it knows what
#to do with each group's buttons.
func chosen_symbol_helper(bool1, bool2, bool3):
	for button in get_tree().get_nodes_in_group("effect_symbols"):
		button.visible = bool1
	for button in get_tree().get_nodes_in_group("type_symbols"):
		button.visible = bool2
	for button in get_tree().get_nodes_in_group("modifier_symbols"):
		button.visible = bool3

#Helper function specifically for figuring out which effects a given modifier can take;
#perhaps a bit finely-wrought, but since there's only going to be five different 2/4
#modifiers, we can get away with coding every little contingency.
#We can actually probably write another helper function for this helper function
#(AAAAAAHHH) that handles the "for list_item" iteration
func slot_four_modifier_effect_finder(symbol):
	var valid_effects = []
	for list_item in valid_slot_three_effects[symbol]:
		if list_item == "suit" or list_item == "ally" or list_item == "enemy":
			#Remember this is here in the future if there are other use-cases for a suit searcher
			var needed_suit = enemy_ally_suit_dict[effect_dict[selected_symbols_list[4]]["slot_five"]["suit"]][list_item]
			for key in effect_dict.keys():
				if (effect_dict[key]["slot_five"]["suit"] == needed_suit
					and
					key != selected_symbols_list[4]):
					valid_effects.append(key)
	for button in get_tree().get_nodes_in_group("effect_symbols"):
		if button.name in valid_effects:
			button.visible = true
		else:
			button.visible = false

func _chosen_symbol_button_pressed(button):
	if (selected_symbols_list[4] == null or selected_type == null) and (button.name != "5" and button.name != "7"):
		$guidance.text = "Please start by selecting your card's type and base effect."
		emit_signal("guidance_changed")
	else:
		current_symbol = int(button.name)
		if ((current_symbol == 1 and selected_symbols_list[1] != null) 
		or (current_symbol == 3 and selected_symbols_list[3] != null)):
			chosen_symbol_helper(false, false, false)
			slot_four_modifier_effect_finder(selected_symbols_list[current_symbol])
		if current_symbol == 2 or current_symbol == 4:
			chosen_symbol_helper(false, false, false)
			for button in get_tree().get_nodes_in_group("modifier_symbols"):
				if button.name in valid_slot_four_modifiers[selected_type]:
					button.visible = true
				else:
					button.visible = false
		if current_symbol == 5:
			chosen_symbol_helper(true, false, false)
		if current_symbol == 6:
			chosen_symbol_helper(false, false, false)
			#This is your model for slots 1-4, where the cardmaker consults the dictionary
			#of viable candidates for a paired slot.
			for button in get_tree().get_nodes_in_group("modifier_symbols"):
				if button.name in valid_slot_six_modifiers[selected_symbols_list[4]][selected_type]:
					button.visible = true
		if current_symbol == 7:
			chosen_symbol_helper(false, true, false)


func _on_clear_button_pressed():
	selected_symbols_list = [null, null, null, null, null, null]
	var text_indexer = 0
	for button in button_list:
		get_node(button).icon = null
		get_node(button).text = button_text[text_indexer]
		text_indexer += 1
	current_symbol = null
	for button in get_tree().get_nodes_in_group("effect_symbols"):
		button.visible = true
	for button in get_tree().get_nodes_in_group("type_symbols"):
		button.visible = true

#Helper function for preview button. Remember that new_card_dict isn't just
#slot_five_dict, but card.slot_five_dict. And be careful of edge cases as we go
#forward.
func card_dictionary_writer_no_search(new_card_dict, source_dict):
	for key in source_dict.keys():
		new_card_dict[key] = source_dict[key]

#Helper function for preview button when it needs to find something other than
#all the keys in one dictionary. Highly modular at this point, and perhaps to a fault:
#see the horribly long search condition below for tomo and teki. As we go forward,
#consider a version that uses something like source + search match + type to represent
#what is currently just search match--ie, grab effect_dict as source if necessary,
#then the particular symbol you're looking in effect_dict, then the type within that
#effect. Might not end up being able to pull this off, but keep an eye on it.
func card_dictionary_writer_with_search(search_match, needed_keys, new_card_dict):
	for key in needed_keys:
		if key in search_match.keys():
			new_card_dict[key] = search_match[key]

func _on_preview_button_pressed():
	if get_node_or_null("card") != null:
		#Works for now as an easy way to allow the player to continue to change
		#their nodes and re-preview the card, but remember down the line that
		#you've been warned that free() can be sketchy compared to queue_free().
		#Ideally this problem will disappear at some point when we make the cardmaker
		#handle this in _process.
		$card.free()
	if selected_symbols_list[4] != null and selected_type != null: 
		# This /\ just checks for the basic stuff needed to make a card,
		# so the "else" statement is way down below after all the cardmaking.
		# When we move to doing slots 1/3 & 2/4 we'll need a check to make sure
		# there's a node in both paired slots. Should be something as simple as
		#four versions of [if 3 but not 4 or etc] and then just throwing some
		#guidance text to tell the player to pair their 1-4 slots; it occurs to me
		#though, we should give the player the option to delete symbols manually
		#if they change their mind about wanting 1/2 or 3/4 to have stuff 
		var card = base_card_template.instance()
		card.name = "card"
		add_child(card)
		card.position = $card_spawn.position
		card.scale = Vector2(.9, .9)
		card.type = selected_type
		card.export_data["type"] = selected_type
		#Grab the appropriate symbol sprites from the selected symbols list, then
		#grab the type sprite last
		for symbol in selected_symbols_list:
			if symbol != null:
				card.sprite_path_list.append("res://sprites/symbols/" + symbol + ".png")
		card.sprite_path_list.append("res://sprites/symbols/" + selected_type + ".png")
		sprite_path = null
		###SLOT 5 WORK BEGINS HERE###
		#
		#
		card_dictionary_writer_no_search(card.slot_five_dict, effect_dict[selected_symbols_list[4]]["slot_five"])
		card_dictionary_writer_no_search(card.slot_five_dict, effect_dict[selected_symbols_list[4]][selected_type])
		###SLOT 6 WORK BEGINS HERE###
		#
		#
		if selected_symbols_list[5] != null:
			#Works for ue, should work for tai. 
			if (selected_symbols_list[5] == "ue"
				or 
				selected_symbols_list[5] == "tai"):
				card_dictionary_writer_no_search(card.slot_six_dict, slot_six_mod_dict[selected_symbols_list[5]])
			else:
			#Works for tomo and teki, should work for kou if we code it carefully.
			#Might need to change this else to an elif for shu, we'll see.
				card_dictionary_writer_no_search(card.slot_six_dict, slot_six_mod_dict[selected_symbols_list[5]])
				card.slot_six_dict["identifier"] = (
													effect_dict[selected_symbols_list[4]]["slot_six"][selected_symbols_list[5]]
													+ card.slot_six_dict["identifier"] 
													)
				card.slot_six_dict["identifier"][0] = card.slot_six_dict["identifier"][0].to_upper()
				card_dictionary_writer_with_search(
											effect_dict[effect_dict[selected_symbols_list[4]]["slot_six"][selected_symbols_list[5]]][selected_type],
											["effect", "effect_int", "activated_ability_cost", "ability_trigger", "targets"],
											 card.slot_six_dict
											)
											#Example of above search condition:
											#hi/tomo in slots five six grabs effect_dict[hi]["slot_six"]["tomo"] = "kaze",
											#then effect_dict[kaze][selected_type] adds the kaze entry for that type
		###SLOT 3/4 WORK BEGINS HERE
		#
		#
		if selected_symbols_list[2] != null and selected_symbols_list[3] != null:
			if selected_symbols_list[3] == "mon":
				#How do we abstract the following two lines?
				card.slot_three_four_dict["symbol_name"] = "mon"
				card.slot_three_four_dict["cost"] = effect_dict[selected_symbols_list[2]]["slot_five"]["cost"] +  5
				card.slot_three_four_dict["identifier"] = (slot_four_mod_dict["mon"]["identifier"] + 
															effect_dict[selected_symbols_list[2]]["omoi"]["identifier"])
				card_dictionary_writer_no_search(card.slot_three_four_dict, slot_four_mod_dict[selected_symbols_list[3]][selected_type])
				card_dictionary_writer_with_search(effect_dict[selected_symbols_list[2]]["omoi"],
													["effect", "effect_int", "targets"], 
													card.slot_three_four_dict)
		card.update()
		$guidance.text = "You can now choose to save or to delete your card."
		emit_signal("guidance_changed")
	else:
		$guidance.text = "A card needs a symbol in slots five and seven."
		emit_signal("guidance_changed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_delete_button_pressed():
	if get_node_or_null("card") != null:
		get_node_or_null("card").queue_free()
		$guidance.text = ""
		selected_symbols_list = [null, null, null, null, null, null]
		selected_type = null
		var text_indexer = 0
		for button in button_list:
			get_node(button).icon = null
			get_node(button).text = button_text[text_indexer]
			text_indexer += 1
		current_symbol = null

func _on_save_pressed():
	if get_node_or_null("card") == null:
		pass
	else:
		#Saving player data locally begins here
		#
		#
		var d = Directory.new()
		if not d.dir_exists("user://test_cards"):
			d.make_dir("user://test_cards")
		var saved_card = File.new()
		saved_card.open("user://test_cards/test_card.save", File.WRITE)
		saved_card.store_string(var2str(get_node("card").export_data))
		#Remember, export_data is currently a dictionary with the list_of_dicts as
		#one value and the sprite_path_list as another.
		saved_card.close()
		#SQLite work begins here
		#
		#
		db.open_db()
		var table = "saved_cards"
		var dict = {}
		var saved_name = ""
		#I have no idea why I had to do the following four lines in the acenine
		#way that I did; it wasn't reading i["symbol_name"]. I'm guessing there's
		#something screwy here with what's pointing to what, but again, this works,
		#and screw this for now.
		for i in get_node("card").list_of_dicts:
			for key in i.keys():
				if key == "symbol_name":
					saved_name += i[key] + " "
		saved_name += get_node("card").type
		dict["name"] = saved_name
		dict["card_data"] = var2str(get_node("card").export_data)
		db.insert_row(table, dict)
		get_node_or_null("card").queue_free()
		$guidance.text = ""
		selected_symbols_list = [null, null, null, null, null, null]
		selected_type = null
		var text_indexer = 0
		for button in button_list:
			get_node(button).icon = null
			get_node(button).text = button_text[text_indexer]
			text_indexer += 1
		current_symbol = null


func _on_cardmaker_guidance_changed():
	$guidance_timer.start()


func _on_guidance_timer_timeout():
	$guidance.text = ""


func _on_clear_symbol_pressed():
	if current_symbol != 7:
		selected_symbols_list[current_symbol - 1] = null
		get_node(button_list[current_symbol - 1]).icon = null
		get_node(button_list[current_symbol - 1]).text = button_text[current_symbol - 1]
		if ((current_symbol == 2 and selected_symbols_list[0] != null) 
			or (current_symbol == 4 and selected_symbols_list[2] != null)):
			selected_symbols_list[current_symbol - 2] = null
			get_node(button_list[current_symbol - 2]).icon = null
			get_node(button_list[current_symbol - 2]).text = button_text[current_symbol - 2]
	else:
		selected_type = null
		get_node(button_list[current_symbol - 1]).icon = null
		get_node(button_list[current_symbol - 1]).text = button_text[current_symbol - 1]
