extends CardBase

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	self.area_entered.connect(_area_entered)
	self.area_exited.connect(_area_exited)
	SignalBus._on_card_destroyed.connect(_on_card_destroyed)
	SignalBus._on_zone_area_entered.connect(self._on_zone_area_entered)
	SignalBus._on_zone_area_exited.connect(self._on_zone_area_exited)
	SignalBus._on_turn_changed.connect(self._on_turn_changed)
	SignalBus._on_card_targeted.connect(_on_card_targeted)
	SignalBus._on_card_selected.connect(_on_card_selected)
	SignalBus._on_card_deselected.connect(_on_card_deselected)
	if opponent:
		SignalBus._on_card_added_to_opponent_hand.emit(self)
	elif card_id != 'Worker':
		SignalBus._on_card_added_to_hand.emit(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)

func _cast_card_ai(target_bias):
	var game_manager = get_parent().get_node('GameManager')
	var opp_cast_zone = get_parent().get_node('CastZone_Opponent')
	var player_cast_zone = get_parent().get_node('CastZone')
	if game_manager.phases[game_manager.phase_index] != 'Main':
		return
	
	print(self.card_id)
	self.draggable = false
	var card_base = "res://New_Implementation/Sprites/New_Card_Base.png"
	if self.card_class == "Knt":
		card_base = "res://Sprites/New_Sprites/New_Card_Base_Knight.png"
	elif self.card_class == "Rge":
		card_base = "res://Sprites/New_Sprites/New_Card_Base_Rogue.png"
	elif self.card_class == "Mge":
		card_base = "res://Sprites/New_Sprites/New_Card_Base_Mage.png"
	if self.ability_trigger == 'Target':
		var card_target
		var rand
		var rng = RandomNumberGenerator.new()
		var target_options
		if self.ability_function == "Buff":
			for val in self.ability_parameters:
				print(self, typeof(val), self.ability_function, self.card_id, self.ability_parameters, " ", val)
				if typeof(val) == 2 and val < 0:
					target_options = player_cast_zone.units_in_zone
				else:
					target_options = opp_cast_zone.units_in_zone
		elif target_bias[self.ability_function] == "Good":
			target_options = opp_cast_zone.units_in_zone
		elif target_bias[self.ability_function] == "Bad":
			target_options = player_cast_zone.units_in_zone
		
		if len(target_options) > 0:
			if opponent:
				UiVariables.player_gold_opponent -= self.gold_cost
				UiVariables.player_arcane_opponent -= self.arcane_cost
			else:
				UiVariables.player_gold -= self.gold_cost
				UiVariables.player_arcane -= self.arcane_cost
			self.position = opp_cast_zone.position
			self.z_index += 1
			SignalBus._on_card_casted.emit(self, opp_cast_zone)
			curr_target = target.instantiate()
			curr_target.line = true
			get_parent().add_child(curr_target)
			self.location = "Cast"
			SignalBus._on_card_selected.emit(self, self.ability_function, self.ability_parameters)
			$Image.visible = true
			$Base.texture = load(card_base)
			$Control/Gold_Cost.visible = true
			$Control/Arcane_Cost.visible = true
			$Control/Name.visible = true
			$Control/Ability.visible = true
			$Control/Type.visible = true
			#$Control/Class.visible = true
			$CardIcon_Arcane.visible = true
			$CardIcon_Gold.visible = true
			await get_tree().create_timer(1.0).timeout
			rand = rng.randi_range(0, len(target_options) - 1)
			card_target = target_options[rand]
			SignalBus._on_card_targeted.emit(card_target)
			SignalBus._on_card_deselected.emit(self)
			SignalBus._on_send_to_grave.emit(self.card_id, self.opponent)
			# SignalBus._on_card_deselected.emit(card_target)
		else:
			return false
	else:
		self.position = opp_cast_zone.position
		SignalBus._on_card_casted.emit(self, curr_zone)
		if opponent:
			UiVariables.player_gold_opponent -= self.gold_cost
			UiVariables.player_arcane_opponent -= self.arcane_cost
		else:
			UiVariables.player_gold -= self.gold_cost
			UiVariables.player_arcane -= self.arcane_cost
		$Image.visible = true
		$Base.texture = load(card_base)
		$Control/Gold_Cost.visible = true
		$Control/Arcane_Cost.visible = true
		$Control/Name.visible = true
		$Control/Ability.visible = true
		$Control/Type.visible = true
		#$Control/Class.visible = true
		$CardIcon_Arcane.visible = true
		$CardIcon_Gold.visible = true
		await get_tree().create_timer(1.0).timeout
		_do_card_effect()
	
	return true
	
func _can_cast():
	var game_manager = get_parent().get_node('GameManager')
	if game_manager.phases[game_manager.phase_index] != 'Main':
		return false
	var safe = false
	if curr_zone and UiVariables.player_gold >= self.gold_cost and UiVariables.player_arcane >= self.arcane_cost and self.location in ['dragged', 'hand'] and !opponent and 'Opponent' not in curr_zone.name and game_manager.turn == 'Player' and not UiVariables.select:
		safe = true
	elif curr_zone and UiVariables.player_gold_opponent >= self.gold_cost and UiVariables.player_arcane_opponent >= self.arcane_cost and self.location in ['dragged', 'hand'] and opponent and 'Opponent' in curr_zone.name  and game_manager.turn == 'Opponent' and not UiVariables.select: 
		safe = true
	if not safe:
		return false

	var opp_cast_zone = get_parent().get_node('CastZone_Opponent')
	var player_cast_zone = get_parent().get_node('CastZone')
	var ability_instance = null
	if 'Target' == self.ability_trigger:
		var ability_scene = load('res://Abilities/' + ability_function + '.tscn')
		ability_instance = ability_scene.instantiate()
		get_parent().add_child(ability_instance)
		var action_target_encoding = ability_instance.TARGET_ENCODING
		var encoding_owner = action_target_encoding[0]
		var encoding_type = action_target_encoding[1]
		if encoding_owner == 'own' and encoding_type == 'unit':
			if game_manager.turn == 'Player' and len(player_cast_zone.units_in_zone) == 0:
				return false
			elif game_manager.turn == 'Opponent' and len(opp_cast_zone.units.in_zone) == 0:
				return false
		elif encoding_owner == 'opponent' and encoding_type == 'unit':
			if game_manager.turn == 'Player' and len(opp_cast_zone.units_in_zone) == 0:
				return false
			elif game_manager.turn == 'Opponent' and len(player_cast_zone.units.in_zone) == 0:
				return false
	return true

func _cast_card():
	self.z_index += 1
	var game_manager = get_parent().get_node('GameManager')
	var opp_cast_zone = get_parent().get_node('CastZone_Opponent')
	var player_cast_zone = get_parent().get_node('CastZone')
	var ability_instance = null
	if not _can_cast():
		return
	self.position = curr_zone.position
	if opponent:
		UiVariables.player_gold_opponent -= self.gold_cost
		UiVariables.player_arcane_opponent -= self.arcane_cost
	else:
		UiVariables.player_gold -= self.gold_cost
		UiVariables.player_arcane -= self.arcane_cost
	self.draggable = false
	SignalBus._on_card_casted.emit(self, curr_zone)
	if self.ability_trigger == 'Target':
		print('do target routine to get parameters')
		UiVariables.mouse_busy = true
		curr_target = target.instantiate()
		curr_target.line = true
		get_parent().add_child(curr_target)
		SignalBus._on_card_selected.emit(self, self.ability_function, self.ability_parameters)
		SignalBus._on_send_to_grave.emit(self.card_id, self.opponent)
		self.location = "Cast"
	else:
		await get_tree().create_timer(1.0).timeout
		_do_card_effect()

func _do_card_effect():
	print("DOING CARD EFFECT")
	var game_manager = get_parent().get_node('GameManager')
	if self.ability_function == "Damage" and typeof(self.ability_parameters) == TYPE_ARRAY and self.ability_parameters[1] == "AllOpp":
		var opp_cast_zone = get_parent().get_node('CastZone_Opponent')
		var player_cast_zone = get_parent().get_node('CastZone')
		var curr_cast_zone
		if game_manager.turn == 'Player':
			curr_cast_zone = opp_cast_zone
		else:
			curr_cast_zone = player_cast_zone
		for unit in curr_cast_zone.units_in_zone:
			SignalBus._on_action_sent_to_queue.emit([self.ability_function, [self.ability_parameters[0], self, unit]])
		SignalBus._on_send_to_grave.emit(self.card_id, self.opponent)
		self.location = 'Grave'
		return
	elif self.ability_function == "Damage" and typeof(self.ability_parameters) == TYPE_ARRAY and self.ability_parameters[1] == "All":
		var opp_cast_zone = get_parent().get_node('CastZone_Opponent')
		var player_cast_zone = get_parent().get_node('CastZone')
		for unit in opp_cast_zone.units_in_zone:
			SignalBus._on_action_sent_to_queue.emit([self.ability_function, [self.ability_parameters[0], self, unit]])
		for unit in player_cast_zone.units_in_zone:
			SignalBus._on_action_sent_to_queue.emit([self.ability_function, [self.ability_parameters[0], self, unit]])
		SignalBus._on_send_to_grave.emit(self.card_id, self.opponent)
		self.location = 'Grave'
		return
	elif self.ability_function == "Buff" and typeof(self.ability_parameters) == TYPE_ARRAY and self.ability_parameters[2] == "AllOpp":
		var opp_cast_zone = get_parent().get_node('CastZone_Opponent')
		var player_cast_zone = get_parent().get_node('CastZone')
		var curr_cast_zone
		if game_manager.turn == 'Player':
			curr_cast_zone = opp_cast_zone
		else:
			curr_cast_zone = player_cast_zone
	
		for unit in curr_cast_zone.units_in_zone:
			SignalBus._on_action_sent_to_queue.emit([self.ability_function, [[self.ability_parameters[0], self.ability_parameters[1]], self, unit]])
		SignalBus._on_send_to_grave.emit(self.card_id, self.opponent)
		self.location = 'Grave'
		return

	SignalBus._on_send_to_grave.emit(self.card_id, self.opponent)
	SignalBus._on_action_sent_to_queue.emit([self.ability_function, [self.ability_parameters]])
	self.location = 'Grave'
	self.queue_free()

func _free():
	print("Freeing")
	await get_tree().create_timer(1).timeout 
	self.queue_free()

	
	
