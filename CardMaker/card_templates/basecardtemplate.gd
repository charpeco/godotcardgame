extends Node2D

var romaji_name = ""
var type = ""
var kanji_name = ""
var cost = 0
var effect_text = ""
var effect_int = 0
var suit = null
var row = null
var serial_id = ""

var sprite_path_list = []

var slot_five_dict = {}
var slot_six_dict = {}

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

func effect_text_update():
	### EOD THOUGHTS 7/29 ARE HERE.
	#We need to figure out an abstract way for it to grab
	#any effect, which means we need to navigate the dilemma of having a generic referrent for abilities while
	#maintaining the effect to distinguish a static effect like haste from a triggered effect like loot.
	###IN A SENSE, THIS IS THE NEXT BIG CHALLENGE NOW THAT WE'VE CLEARED UP A BUNCH OF LITTLE CHALLENGES--we need
	#to start moving towards figuring out how to actually CODE abilities rather than just pass text around.
	#After all, the generic effect problem above isn't really a huge deal just for this function--we could just
	#call everything effect and be fine for passing it in here. It's only once the cards actually start doing stuff
	#that it matters what the effect in question actually refers to.
	if type == "karada":
		#This is good, but it'll be better/more futureproof if we create some kind of list of abilities
		#so that we can handle both "with {ability} and {ability}" and "with {ability}, {ability},
		#and {ability}."
		var prep_string = "Summon a {0}"
		var placeholder_list = [slot_five_dict["identifier"] + " with " + slot_five_dict["effect"]]
		if "effect_int" in slot_five_dict.keys():
				placeholder_list[0] += " " + str(slot_five_dict["effect_int"])
		if slot_six_dict.empty() != true:
			#I'm not sure if this should be the basic idea for working with strings like this in the
			#future--the list strategy is likely to produce some headaches down the line
			#once we're working with seven nodes. We'll probably want to change over to dictionaries
			#when we get further in, but again, this concatenate generic string to prep string +
			#append particular data to data structure then format at the end is the basic idea.
			prep_string += " and {1}"
			placeholder_list.append(slot_six_dict["effect"])
			if "effect_int" in slot_six_dict.keys():
				placeholder_list[1] += " " + str(slot_six_dict["effect_int"])
		$effect_text_label.text = prep_string.format(placeholder_list) + "."

func symbol_sprite_update():
#	There's certainly more fussing that can be done over scaling and positioning,
#	but for now, this works.
	var height = $frame.texture.get_height()
	var width = $frame.texture.get_width()
	var symbol_sprites_iterable = get_tree().get_nodes_in_group("symbol_sprites")
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
