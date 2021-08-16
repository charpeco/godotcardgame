extends Node2D

const base_card_template = preload("res://card_templates/basecardtemplate.tscn")
var content = null
const test_card = "user://test_cards/test_card.save"

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
	card.position = $card_spawn.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
