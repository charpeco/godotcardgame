extends Node2D

var sprite_path = null
var search_condition = null
const card_save_path = "user://"

const sqlite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db = null
var db_name = "res://sqlite_data/database.db"

#This gets filled by looping in _ready because there's a bunch of stuff in it and it'll be a pain
#to maintain going forward.
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
						"ue" : {"symbol_name" : "ue",
								"cost" : 1.5,
								#Occurs to me that one modifier name for each
								#type might be too narrow; consider adding different
								#adjectives for different types.
								"identifier" : "Enhanced",
								"effect" : "enhance",
								"search" : false},
						"tomo" : {"symbol_name" : "tomo",
								"cost" : 2,
								"identifier" : "-allied",
								"search" : true},
						"teki" : {"symbol_name" : "teki",
									"cost" : 2.5,
									"identifier" : "-allied",
									"search" : true
									}
						}

#Not presently in use, but kept it in case we need it down the line
const enemy_ally_suit_dict = {
								"clubs" : {
											"ally" : "spades",
											"enemy" : "hearts"
								},
								"hearts" : {
											"ally" : "diamonds",
											"enemy" : "spades"
								},
								"spades" : {
											"ally" : "clubs",
											"enemy" : "diamonds"
								},
								"diamonds" : {
											"ally" : "hearts",
											"enemy" : "clubs"
								},
								}

#All the following are upkeep for the cardmaker itself
var selected_symbols_list = [null, null, null, null, null, null]
var selected_type = null
const button_list = ["chosen_symbols/1", "chosen_symbols/2",
					"chosen_symbols/3", "chosen_symbols/4",
					"chosen_symbols/5", "chosen_symbols/6",
					"chosen_symbols/7"]
const button_text = ["Effect", "Modifier", "Effect", "Modifier", "Effect", "Modifier", "Type"]
var current_symbol = null

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
	for button in get_tree().get_nodes_in_group("effect_symbols"):
		button.connect("pressed", self, "_effect_button_pressed", [button])
		var sprite_dict_key = button.name
		var sprite_dict_value = str(button.texture_normal.get_load_path())
		symbol_sprite_dict[sprite_dict_key] = load(sprite_dict_value)
#\/ This and the corresponding connected function are currently redundant with 
# _effect_button_pressed; condense them if no meaningful difference emerges.
	for button in get_tree().get_nodes_in_group("modifier_symbols"):
		button.connect("pressed", self, "_modifier_button_pressed", [button])
		var sprite_dict_key = button.name
		var sprite_dict_value = str(button.texture_normal.get_load_path())
		symbol_sprite_dict[sprite_dict_key] = load(sprite_dict_value)
	
	for button in get_tree().get_nodes_in_group("type_symbols"):
		button.connect("pressed", self, "_type_button_pressed", [button])
		var sprite_dict_key = button.name
		var sprite_dict_value = str(button.texture_normal.get_load_path())
		symbol_sprite_dict[sprite_dict_key] = load(sprite_dict_value)
	
	for button in get_tree().get_nodes_in_group("chosen_symbol_buttons"):
		button.connect("pressed", self, "_chosen_symbol_button_pressed", [button])
	db = sqlite.new()
	db.path = db_name

# Again, the following two functions are currently redundant
func _effect_button_pressed(button):
	if current_symbol:
		get_node(button_list[current_symbol - 1]).text = ""
		get_node(button_list[current_symbol - 1]).icon = symbol_sprite_dict[button.name]
		selected_symbols_list[current_symbol - 1] = button.name

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

func _chosen_symbol_button_pressed(button):
	current_symbol = int(button.name)
	if current_symbol == 1 or current_symbol == 3 or current_symbol == 5:
		for button in get_tree().get_nodes_in_group("effect_symbols"):
			button.disabled = false
		for button in get_tree().get_nodes_in_group("type_symbols"):
			button.disabled = true
		for button in get_tree().get_nodes_in_group("modifier_symbols"):
			button.disabled = true
	if current_symbol == 2 or current_symbol == 4 or current_symbol == 6:
		for button in get_tree().get_nodes_in_group("effect_symbols"):
			button.disabled = true
		for button in get_tree().get_nodes_in_group("type_symbols"):
			button.disabled = true
		for button in get_tree().get_nodes_in_group("modifier_symbols"):
			button.disabled = false
	if current_symbol == 7:
		for button in get_tree().get_nodes_in_group("effect_symbols"):
			button.disabled = true
		for button in get_tree().get_nodes_in_group("type_symbols"):
			button.disabled = false
		for button in get_tree().get_nodes_in_group("modifier_symbols"):
			button.disabled = true


func _on_clear_button_pressed():
	selected_symbols_list = [null, null, null, null, null, null]
	var text_indexer = 0
	for button in button_list:
		get_node(button).icon = null
		get_node(button).text = button_text[text_indexer]
		text_indexer += 1
	current_symbol = null
	for button in get_tree().get_nodes_in_group("effect_symbols"):
		button.disabled = false
	for button in get_tree().get_nodes_in_group("type_symbols"):
		button.disabled = false



func _on_preview_button_pressed():
	if get_node_or_null("card") != null:
		#Works for now as an easy way to allow the player to continue to change
		#their nodes and re-preview the card, but remember down the line that
		#you've been warned that free() can be sketchy compared to queue_free().
		#Ideally this problem will disappear at some point when we make the cardmaker
		#handle this in _process, but this is still an improvement for today.
		$card.free()
	if selected_symbols_list[4] != null and selected_type != null: 
		# This /\ just checks for the basic stuff needed to make a card,
		# so the "else" statement is way down below after all the cardmaking.
		# When we move to doing slots 1/3 & 2/4 we'll need a check to make sure
		# there's a node in both paired slots.
		var card = base_card_template.instance()
		card.name = "card"
		add_child(card)
		card.position = $card_spawn.position
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
		for key in effect_dict[selected_symbols_list[4]]["slot_five"].keys():
			card.slot_five_dict[key] = effect_dict[selected_symbols_list[4]]["slot_five"][key]
		for key in effect_dict[selected_symbols_list[4]][selected_type].keys():
			card.slot_five_dict[key] = effect_dict[selected_symbols_list[4]][selected_type][key]
		###SLOT 6 WORK BEGINS HERE###
		if selected_symbols_list[5] != null:
			#Works for ue, should work for tai, futata. The iteration two lines down is so that
			#the card's dictionary has a different reference in memory than the dictionary tied to this
			#node. Although I suppose that, with that in mind, we could (AAAAAAAHHHH) refactor the code
			#somewhere down the line so that everything--cardmaker, cards, battelfield--are all using
			#the same information rather than creating tons of copies of it. We'll see.
			if slot_six_mod_dict[selected_symbols_list[5]]["search"] == false:
				for key in slot_six_mod_dict[selected_symbols_list[5]].keys():
					card.slot_six_dict[key] = slot_six_mod_dict[selected_symbols_list[5]][key]
					card.slot_six_dict.erase("search")
			else:
			#Works for tomo, should work for teki, should work for kou if we code it carefully
				card.slot_six_dict["symbol_name"] = slot_six_mod_dict[selected_symbols_list[5]]["symbol_name"]
				card.slot_six_dict["cost"] = slot_six_mod_dict[selected_symbols_list[5]]["cost"]
				var search_match = effect_dict[selected_symbols_list[4]]["slot_six"][selected_symbols_list[5]]
				#Example: hi/tomo in slots five six grabs effect_dict[hi]["slot_six"]["tomo"] = "kaze"
				card.slot_six_dict["identifier"] = (
													search_match
													+ slot_six_mod_dict[selected_symbols_list[5]]["identifier"] 
													)
				###KEEP THIS DICT IN MIND FOR LATER; WE'LL CERTAINLY BE DOING SOMETHING SIMILAR TO THIS
				#IN OTHER PLACES, SO WE MIGHT WANT EITHER TO DECLARE THIS VARIABLE AT A HIGHER LEVEL
				#OR RECYCLE THIS MODEL FOR OTHER SLIGHTLY DIFFERENT CASES.
				var needed_keys = [
									"effect", "effect_int", "activated_ability_cost",
									"ability_trigger", "targets"
									]
				for key in needed_keys:
					if key in effect_dict[search_match][selected_type].keys():
						card.slot_six_dict[key] = effect_dict[search_match][selected_type][key]
		print(card.slot_six_dict)
		card.update()
		$guidance.text = "You can now choose to save or to delete your card."
	else:
		$guidance.text = "A card needs a symbol in slots five and seven."


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
		db.open_db()
		var table = "saved_cards"
		var dict = {}
		var saved_name = ""
		#I have no idea why I had to do the following four lines in the acenine
		#way that I did; it wasn't reading i["symbol_name"]. I'm guessing there's
		#something screwy here with what's pointing to what, but again, this works,
		#and screw this for now.
		for i in get_node("card").list_of_dicts:
			print(i)
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
