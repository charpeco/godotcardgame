extends Node2D

const base_card_template = preload("res://card_templates/basecardtemplate.tscn")
var content = null
const test_card = "user://test_cards/test_card.save"

const sqlite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db = null
var db_name = "res://sqlite_data/database.db"

func load_from_file():
	var file = File.new()
	if file.file_exists(test_card):
		file.open(test_card, File.READ)
		content = str2var(file.get_as_text())
		file.close()
		var card = base_card_template.instance()
		card.slot_five_dict = content["export_list_of_dicts"][0]
		card.slot_six_dict = content["export_list_of_dicts"][1]
		card.sprite_path_list = content["export_sprite_path_list"]
		card.type = content["type"]
		card.list_of_dicts = [card.slot_five_dict, card.slot_six_dict]
		add_child(card)
		card.update()
		card.position = $card_spawn.position

func read_from_db():
	var width = get_viewport().size.x
	var height = get_viewport().size.y
	db.open_db()
	var table = "saved_cards"
	db.query("select * from " + table + ";")
	var x_adjust = .175
	var y_adjust = .33
	var x_counter = 0
	var y_counter = 0
#Currently formatted to hold ~15 cards on screen
	for i in range(0, db.query_result.size()):
		var db_card = base_card_template.instance()
		var db_card_content = str2var(db.query_result[i]["card_data"])
		db_card.slot_five_dict = db_card_content["export_list_of_dicts"][0]
		db_card.slot_six_dict = db_card_content["export_list_of_dicts"][1]
		db_card.sprite_path_list = db_card_content["export_sprite_path_list"]
		db_card.type = db_card_content["type"]
		db_card.list_of_dicts = [db_card.slot_five_dict, db_card.slot_six_dict]
		db_card.name = db.query_result[i]["name"]
		add_child(db_card)
		db_card.position.x = width * (x_adjust * x_counter)
		db_card.position.y = height * (y_adjust * y_counter)
		if x_counter < 5:
			x_counter += 1
		else:
			x_counter = 0
			y_counter += 1
		db_card.scale = Vector2(.55, .55)
		db_card.update()

# Called when the node enters the scene tree for the first time.
func _ready():
#	load_from_file()
	db = sqlite.new()
	db.path = db_name
	read_from_db()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
