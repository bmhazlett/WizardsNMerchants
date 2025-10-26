extends Node
var target_line = preload("res://Scenes/target_line.tscn")
var target = preload("res://Abilities/Target.tscn")
# Assign, Main, End

var target_bias = {"Buff": "Good", "Damage": "Bad"}

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus._on_turn_changed.connect(_on_turn_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _evaluate_position(bias):
	# bais [unit_weight, card_weight, health_weight]
	# +1 for each creature in play more than opponent
	var opp_field = get_parent().get_node('CastZone_Opponent')
	var play_field = get_parent().get_node('CastZone')
	var unit_value = (len(opp_field.units_in_zone) - len(play_field.units_in_zone)) * bias[0]
	print("UNIT VALUE: ", unit_value)
	# +1 for each card in hand more than opponent
	var opp_hand = get_parent().get_node('Hand_Opponent')
	var play_hand = get_parent().get_node('Hand')
	var hand_value = (len(opp_hand.cards_in_hand) - len(play_hand.cards_in_hand)) * bias[1]
	print("HAND VALUE: ", hand_value)
	# +1 for each health more than opponent
	var opp_player_card = get_parent().get_node('Player_Card_Opponent')
	var player_player_card = get_parent().get_node('Player_Card')
	
	var health_value = ((opp_player_card.hp - opp_player_card.damage) - (player_player_card.hp - player_player_card.damage)) * bias[2]
	print("HEALTH VALUE: ", health_value)
	var total_value = unit_value + hand_value + health_value
	print("TOTAL VALUE: ", total_value)
	return

func choose_allocation():
	print('chosing allocation')
	var game_manager = get_parent().get_node('GameManager')
	for worker in game_manager.opponent_workers:
		worker.swap()
	
func make_play():
	print('making plays')
	var opp_hand = get_parent().get_node('Hand_Opponent')
	for card in opp_hand.cards_in_hand:
		if card.arcane_cost <= UiVariables.player_arcane_opponent and card.gold_cost <= UiVariables.player_gold_opponent:
			var success = await card._cast_card_ai(target_bias)
			if success:
				print("Casting", card, card.card_id)
				return true
	return false

func attack():
	var opp_field = get_parent().get_node('CastZone_Opponent')
	var play_field = get_parent().get_node('CastZone')
	var action_scene = load("res://Abilities/" + "Attack"+ ".tscn")
	var action_instance = action_scene.instantiate()
	get_parent().add_child(action_instance)
	var unit_list = opp_field.units_in_zone
	var done = false
	for unit in unit_list:
		print("Looking at", unit, unit.card_id)
		if not done:
			var curr_target = target.instantiate()
			curr_target.line = true
			get_parent().add_child(curr_target)
			SignalBus._on_card_selected.emit(unit, 'Attack', unit.attack)
			await get_tree().create_timer(1.0).timeout
			var rng = RandomNumberGenerator.new()
			var target
			var found_legal_target = false
			while !found_legal_target:
				if len(play_field.units_in_zone) > 0:
					var rand = rng.randi_range(0, len(play_field.units_in_zone) -1)
					target = play_field.units_in_zone[rand]
				else:
					target  = get_parent().get_node('Player_Card')
				print(target)
				if action_instance.is_legal_target(unit, target):
					found_legal_target = true
				
			SignalBus._on_card_targeted.emit(target)
			#SignalBus._on_card_deselected.emit(unit)
			#SignalBus._on_card_deselected.emit(target)
		else:
			break

func start_ai_control():
	var game_manager = get_parent().get_node('GameManager')
	print("START AI CONTROL")
	_evaluate_position([1,1,1])
	await get_tree().create_timer(1.0).timeout
	self.choose_allocation()
	# Phase Change to main
	SignalBus._on_phase_change.emit()
	await get_tree().create_timer(1.0).timeout
	# Play cards / attack / etc
	var play_made = true
	while play_made:
		play_made = await self.make_play()
		await get_tree().create_timer(1.5).timeout
	await self.attack()

	print('Plays Done!')
	await get_tree().create_timer(1.0).timeout
	# Phase change to end turn 
	SignalBus._on_phase_change.emit()
	print('Your Turn!')
	# Phase change to opponents turn
	#SignalBus._on_phase_change.emit()

func _on_turn_changed():
	var game_manager = get_parent().get_node('GameManager')
	if game_manager.turn == "Opponent":
		self.start_ai_control()
	
