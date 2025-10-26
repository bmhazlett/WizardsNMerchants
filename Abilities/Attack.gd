extends Node

# [owner, type]
var TARGET_ENCODING = ['opponent', 'all']

func _ready():
	pass

# Arguments is [action, [source.damage, target,damage], source, target]
func execute(arguements):
	print("Attack: ", arguements)
	if len(arguements) < 3:
		return
	var damage_input = arguements[0]
	var card_1 = arguements[1]
	var card_2 = arguements[2]
	card_1.attacking = true
	card_1.starting_position = card_1.position
	card_1.target_position = card_2.position
	await get_tree().create_timer(.1).timeout
	var action_scene = load("res://Abilities/" + "Damage" + ".tscn")
	var action_instance = action_scene.instantiate()
	get_parent().add_child(action_instance)
	action_instance.execute([card_1.attack, card_1, card_2])
	action_instance.execute([card_2.attack, card_2, card_1])
	card_1.attacked = true

func is_legal_target(source, target):
	var game_manager = get_parent().get_node('GameManager')
	var opp_field = get_parent().get_node('CastZone_Opponent')
	var play_field = get_parent().get_node('CastZone')
	print("Attack is_legal_target", source, target)
	var blocker = false
	if game_manager.turn == "Player":
		for unit in opp_field.units_in_zone:
			if unit.blocking == true:
				blocker = true
	else:
		for unit in play_field.units_in_zone:
			if unit.blocking == true:
				blocker = true
	if blocker and !target.blocking:
		return false
	return true

func _free():
	await get_tree().create_timer(1).timeout 
	self.queue_free()
	
