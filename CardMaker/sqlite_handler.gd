extends Node2D


const sqlite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db = null
var db_name = "res://sqlite_data/database.db"

func commit_to_db():
	db.open_db()
	var table = "player_info"
	var dict = {}
	dict["name"] = "Cory"
	dict["cardsincollection"] = 1
	db.insert_row(table, dict)

func read_from_db():
	db.open_db()
	var table = "player_info"
	db.query("select * from " + table + ";")
	for i in range(0, db.query_result.size()):
		print("Query results ", db.query_result[i]["name"], " ", db.query_result[i]["cardsincollection"])

func _ready():
	db = sqlite.new()
	db.path = db_name
#	read_from_db()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
