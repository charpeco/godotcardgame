extends Node2D

const base_card_template = preload("res://card_templates/basecardtemplate.tscn")
var content = null
const test_card = "user://test_cards/test_card.save"

const sqlite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db = null
var db_name = "res://sqlite_data/database.db"

var test_deck = []
var test_graveyard = []
var cards_drawn_total = 0

var target = null
signal target_chosen

func load_from_file():
	var file = File.new()
	if file.file_exists(test_card):
		file.open(test_card, File.READ)
		content = str2var(file.get_as_text())
		file.close()

func load_db_as_deck():
	db.open_db()
	var table = "saved_cards"
	db.query("select * from " + table + ";")
	for i in range(0, db.query_result.size()):
		var deck_card_content = str2var(db.query_result[i]["card_data"])
		test_deck.append(deck_card_content)
	randomize()
	test_deck.shuffle()

# Called when the node enters the scene tree for the first time.
func _ready():
	#All the lines below are commented for now because we're loading from DB
	#rather than user path at the moment
#	load_from_file()
#	var card = base_card_template.instance()
#	card.slot_five_dict = content["export_list_of_dicts"][0]
#	card.slot_six_dict = content["export_list_of_dicts"][1]
#	card.sprite_path_list = content["export_sprite_path_list"]
#	card.type = content["type"]
#	add_child(card)
#	card.update()
#	card.scale = Vector2(.5, .5)
#	card.position = $hand_one.position
	db = sqlite.new()
	db.path = db_name
	load_db_as_deck()
	
	for button in get_tree().get_nodes_in_group("targeting_buttons"):
		button.connect("pressed", self, "_on_targeting_button_pressed", [button.get_parent().name])
		button.hide()

func alter_life(amount):
	get_node(target).set_health(amount)

func alter_power(amount):
	get_node(target).set_power(amount)

func alter_min_power(amount):
	get_node(target).set_min_power(amount)

func draw_a_card(amount):
	var cards_drawn_this_function = 0
	while cards_drawn_this_function < amount:
		#It's a little weird that we're only processing the data from the
		#database as cards are drawn; consider making all the cards
		#at once in ready(), then just hiding them and moving/showing them
		#as necessary.
		var deck_card = base_card_template.instance()
		deck_card.slot_five_dict = test_deck[0]["export_list_of_dicts"][0]
		deck_card.slot_six_dict = test_deck[0]["export_list_of_dicts"][1]
		deck_card.slot_three_four_dict = test_deck[0]["export_list_of_dicts"][2]
		deck_card.slot_one_two_dict = test_deck[0]["export_list_of_dicts"][3]
		deck_card.sprite_path_list = test_deck[0]["export_sprite_path_list"]
		deck_card.type = test_deck[0]["type"]
		deck_card.name = str(cards_drawn_total)
		add_child(deck_card)
		deck_card.scale = Vector2(.55, .55)
		deck_card.update()
		###Obviously we're gonna need a more dynamic way to update these positions;
		#for now, breaks after the seventh card is drawn
		deck_card.position = get_tree().get_nodes_in_group("hand_positions")[cards_drawn_total].position
		cards_drawn_total += 1
		test_graveyard.append(test_deck[0])
		test_deck.remove(0)
		cards_drawn_this_function += 1

func choose_target(targets):
	#Works, just need to add more targeting scenarios as they come up
	$guidance.text = "Choose a target"
	if targets == "opponent_all":
		$opp_placeholder/targeting_button.show()
		$test_creature/test_creature_button.show()
		yield(self, "target_chosen")
		$opp_placeholder/targeting_button.hide()
		$test_creature/test_creature_button.hide()
	if targets == "opponent_creatures":
		$test_creature/test_creature_button.show()
		yield(self, "target_chosen")
		$test_creature/test_creature_button.hide()
	$guidance.text = ""

func process_effect(effect, effect_int):
	if effect == "damage":
		alter_life(effect_int * -1)
	if effect == "depower":
		alter_power(effect_int * -1)
	if effect == "ransack":
		draw_a_card(effect_int)
		###STILL NEED TO CODE DISCARDING
	if effect == "ferocity":
		alter_min_power(effect_int)
		alter_power(effect_int)

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

func _on_targeting_button_pressed(parent_name):
	target = parent_name
	emit_signal("target_chosen")

func _on_draw_card_button_pressed():
	draw_a_card(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
