extends Node


func execute(parameters):
	var game_manager = get_parent().get_node('GameManager')
	var gold_to_add = parameters[0]
	var turn = game_manager.turn
	if turn == 'Player':
		UiVariables.player_gold += gold_to_add
	else:
		UiVariables.player_gold_opponent += gold_to_add
	_free()

func _free():
	await get_tree().create_timer(1).timeout 
	self.queue_free()
