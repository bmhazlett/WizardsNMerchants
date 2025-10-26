extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func execute(parameters):
	var amount = parameters[0]
	var target = parameters[1]
	print("Thieve ", target.type)
	if target.type != 'Unit':
		_free()
		return
	var game_manager = get_parent().get_node('GameManager')
	var turn = game_manager.turn
	var final_amount = amount
	if turn == 'Opponent':
		UiVariables.player_gold_opponent += amount
	else:
		UiVariables.player_gold += amount
	_free()

func _free():
	await get_tree().create_timer(1).timeout
	self.queue_free()
