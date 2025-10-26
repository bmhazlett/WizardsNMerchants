extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func execute(parameters):
	var amount = parameters[0]
	var game_manager = get_parent().get_node('GameManager')
	var turn = game_manager.turn
	if turn == 'Opponent':
		UiVariables.player_arcane_opponent += amount * 2
	else:
		UiVariables.player_arcane += amount * 2
	_free()

func _free():
	await get_tree().create_timer(1).timeout
	self.queue_free()
