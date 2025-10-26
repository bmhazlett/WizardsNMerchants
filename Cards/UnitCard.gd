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
	var card_base = load("res://New_Implementation/Sprites/New_Card_Base.png")
	if self.card_class == "Knt":
		card_base = load("res://Sprites/New_Sprites/New_Card_Base_Knight.png")
	elif self.card_class == "Rge":
		card_base = load("res://Sprites/New_Sprites/New_Card_Base_Rogue.png")
	elif self.card_class == "Mge":
		card_base = load("res://Sprites/New_Sprites/New_Card_Base_Mage.png")
	if game_manager.phases[game_manager.phase_index] != 'Main' or  opp_cast_zone.count_units >= 5 :
		return
	self.z_index -= 1
	self.position = opp_cast_zone.position
	if opponent:
		UiVariables.player_gold_opponent -= self.gold_cost
		UiVariables.player_arcane_opponent -= self.arcane_cost
	else:
		UiVariables.player_gold -= self.gold_cost
		UiVariables.player_arcane -= self.arcane_cost
	self.location = 'play'
	self.draggable = false
	#$Image.scale = $Base.texture.get_size()/$Image.texture.get_size()/2.3
	#$Image.position.y += 25
	$Control/Gold_Cost.visible = true
	$Control/Arcane_Cost.visible = true
	$Control/Name.visible = true
	$Control/Ability.visible = true
	$Control/Type.visible = true
	#$Control/Class.visible = true
	$Control/HP.visible = true
	$Control/Attack.visible = true
	$Control/Rarity.visible = true
	$Image.visible = true
	$Base.texture = card_base
	$CardIcon_Attack.visible = true
	$CardIcon_Health.visible = true
	$CardIcon_Arcane.visible = true
	$CardIcon_Gold.visible = true
	
	self.selectable = true
	if 'Cast' == self.ability_trigger or 'Static' == self.ability_trigger:
		var ability_scene = load('res://Abilities/' + ability_function + '.tscn')
		var ability_instance = ability_scene.instantiate()
		get_parent().add_child(ability_instance)
		ability_instance.execute([ability_parameters])
		ability_instance.queue_free()
	SignalBus._on_card_casted.emit(self, opp_cast_zone)
	return true

func is_legal_target(source, target, action):
	var game_manager = get_parent().get_node('GameManager')
	var opp_field = get_parent().get_node('CastZone_Opponent')
	var play_field = get_parent().get_node('CastZone')
	print("is_legal_target", source, target, action)
	if action == "Attack":
		print("Attack")
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
