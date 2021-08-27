extends Node


const type_starters = {"karada" : "Summon a {identifier} {effect}",
						"mono" : "Create a {identifier}",
						"omoi" : "{effect}"}

const effect_texts_dict = {"haste" : " that can attack the turn you summon it ",
						"panic" : " {effect_int} creatures can't block this turn ",
						"ransack" : " draw {effect_int} cards, then discard {effect_int} cards ",
						"damage" : " deal {effect_int} damage to {targets} ",
						"ferocity" : " with {effect_int} extra power that can't be reduced",
						"depower" : " reduce {targets} 's power by {effect_int}"}

const effect_triggers_dict = {"any_damage_player" : "Whenever a creature deals damage to your opponent, ",
							"self_damage_player" : "Whenever this deals damage to your opponent, ",
							"on_block" : "Whenever this blocks, ",
							"player_turn_start" : "At the beginning of your turn, "}

const targets_dict = {"opponent_all" : "your opponent or one of their creatures",
						"opponent_creatures" : "one of your opponent's creatures",
						"blocked_creature" : "the creature it blocked"}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
