#We can later change the "create card" button to a "preview card" button that
#then gives the player the option to delete or save it

extends Node2D

export(PackedScene) var card_scene
var selected_symbols = [null, null, null, null, null, null, null]
var button_list = ["one_button", "two_button", "three_button", "four_button",
					"five_button", "six_button", "seven_button"]
var button_text = ["Effect", "Modifier", "Effect", "Modifier", "Effect", "Modifier", "Type"]
var current_symbol = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _process(delta):
	pass

#Make the grid containing all these buttons its own node so that it can be a child
#of cardmaker itself so that we don't need to have like 200-300 lines of these same
#functions in the main cardmaker script
func _on_hi_button_pressed():
	var hi = $symbols.hi
	get_node(button_list[current_symbol]).text = ""
	get_node(button_list[current_symbol]).icon = hi["sprite"]
	selected_symbols[current_symbol] = hi



func _on_mono_button_pressed():
	var mono = $symbols.mono
	get_node(button_list[current_symbol]).text = ""
	get_node(button_list[current_symbol]).icon = mono["sprite"]
	selected_symbols[current_symbol] = mono


func _on_omoi_button_pressed():
	var omoi = $symbols.omoi
	get_node(button_list[current_symbol]).text = ""
	get_node(button_list[current_symbol]).icon = omoi["sprite"]
	selected_symbols[current_symbol] = omoi


func _on_create_card_pressed():
	var card = card_scene.instance()
	for symbol in selected_symbols:
		if symbol:
			#The following "sprite" should probably be rewritten to "symbol_sprite" for clarity
			card.symbols.append(symbol["sprite"])
			card.name_text.append(symbol["name_text"])
			card.effect_text.append(symbol["effect_text"])
			#We might wanna make the following something a little broader than "creature" and
			#have the creature sprite be part of the node that also contains the spell
			#effects. Ie, whereas now the creature is just the goblin sprite, instead have
			#what's now the goblin class be the hi class, which includes the goblin
			#sprite. This brings us back to the dictionary vs. child node question,
			#but I think we now have a stronger case for the child node approach.
			#I guess the system would involve adding the child nodes as effect1, effect2
			#etc, and then having the card template node get all that stuff on _ready().
			#
			#ON FURTHER THOUGHT, I think that cards should be created with the minimum amount of
			#information possible. If a card is a creature spell, then it shouldn't be getting
			#the non-creature spell effects. So we need to thread the needle here between 
			#processing here and processing in the card itself. Continuing with the creature
			#example, there should definitely be a "goblin creature" node that the card gets
			#and can then pass to its parent (ie, the battlefield). 
			#The more complicated case is blessed creatures. Should the card get the actual
			#creature and the bless effect, or should it just get a node that's bless + creature?
			if "creature" in symbol.keys():
				var creature = symbol["creature"].instance()
				creature.set_name("creature")
				card.add_child(creature)
	card.position = $card_spawn.position
	add_child(card)
	for symbol in selected_symbols:
		symbol = null
	var text_indexer = 0
	for button in button_list:
		get_node(button).icon = null
		get_node(button).text = button_text[text_indexer]
		text_indexer += 1
	current_symbol = null


func _on_seven_button_pressed():
	current_symbol = 6


func _on_six_button_pressed():
	current_symbol = 5


func _on_five_button_pressed():
	current_symbol = 4


func _on_four_button_pressed():
	current_symbol = 3


func _on_three_button_pressed():
	current_symbol = 2


func _on_two_button_pressed():
	current_symbol = 1


func _on_one_button_pressed():
	current_symbol = 0


func _on_clear_button_pressed():
	for symbol in selected_symbols:
		symbol = null
	var text_indexer = 0
	for button in button_list:
		get_node(button).icon = null
		get_node(button).text = button_text[text_indexer]
		text_indexer += 1
	current_symbol = null


func _on_naku_button_pressed():
	var naku = $symbols.naku
	get_node(button_list[current_symbol]).text = ""
	get_node(button_list[current_symbol]).icon = naku["sprite"]
	selected_symbols[current_symbol] = naku


func _on_sei_button_pressed():
	var sei = $symbols.sei
	get_node(button_list[current_symbol]).text = ""
	get_node(button_list[current_symbol]).icon = sei["sprite"]
	selected_symbols[current_symbol] = sei
