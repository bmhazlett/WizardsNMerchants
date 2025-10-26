extends Node2D
class_name CardBase

var dragging = false
var curr_zone = null

var card_id = 'Witch';
var curr_area = null
var card_name = ''
var cost = ''
var ability = ''
var card_class = ''
var type =  ''
var attack = ''
var hp = ''
var attack_mod = 0
var hp_mod = 0
var base_hp
var base_attack
var damage = 0
var art = ''
var card_mode = ''
var ability_trigger = ''
var ability_function = ''
var ability_parameters = ''
var gold_cost = cost.count('G')
var arcane_cost = cost.count('A')
var location = 'hand'
var draggable = true
var opponent = false
var target_line = preload("res://Scenes/target_line.tscn")
var target = preload("res://Abilities/Target.tscn")
var action_menu = preload("res://testing/action_menu.tscn")
var curr_line = null
var attacked = false
var selectable = false
var selected = false
var curr_target = null
var blocking = false
var menu_up = false
var rarity = 'C'
var attacking
var starting_position
var target_position
var ATTACK_SPEED = 1000
var destroyed = false
var areas_overlapped = []
var additional_costs
var additional_costs_parameters
var thieve_scene = preload("res://Abilities/Thieve.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	print("IM READY IM READY")
	SignalBus._on_chose_attack.connect(_on_chose_attack)
	SignalBus._on_chose_block.connect(_on_chose_block)
	SignalBus._on_chose_ability.connect(_on_chose_ability)
	SignalBus._after_damage_dealt.connect(_after_damage_dealt)
	SignalBus._on_card_death.connect(_on_card_death)
	SignalBus._on_card_casted.connect(_on_card_casted)
	card_name = CardDB.CARD_DB[card_id]['Name']
	cost = CardDB.CARD_DB[card_id]['Cost']
	ability = CardDB.CARD_DB[card_id]['Ability']
	card_class = CardDB.CARD_DB[card_id]['Class']
	type =  CardDB.CARD_DB[card_id]['Type']
	attack = int(CardDB.CARD_DB[card_id]['Attack'])
	rarity = str(CardDB.CARD_DB[card_id]['Rarity'])
	base_attack = attack
	hp = int(CardDB.CARD_DB[card_id]['HP'])
	base_hp = hp
	art = CardDB.CARD_DB[card_id]['Art']
	ability_trigger = CardDB.CARD_DB[card_id]['Ability_Trigger']
	ability_function = 	CardDB.CARD_DB[card_id]['Ability_Function']
	ability_parameters = CardDB.CARD_DB[card_id]['Ability_Parameters']
	additional_costs = CardDB.CARD_DB[card_id]['Additional_Costs']
	additional_costs_parameters = CardDB.CARD_DB[card_id]['Additional_Costs_Parameters']
	if typeof(ability_parameters) == TYPE_ARRAY:
		ability_parameters += [self]
	print(self.card_name, ability_parameters)
	if self.card_class == "Knt":
		$Base.texture = load("res://Sprites/New_Sprites/New_Card_Base_Knight.png")
	elif self.card_class == "Rge":
		$Base.texture = load("res://Sprites/New_Sprites/New_Card_Base_Rogue.png")
	elif self.card_class == "Mge":
		$Base.texture = load("res://Sprites/New_Sprites/New_Card_Base_Mage.png")
	var card_img = str("res://")
	if self.opponent:
		var card_base = str("res://Sprites/New_Card_Back.png")
		$Control/Gold_Cost.visible = false
		$Control/Arcane_Cost.visible = false
		$Control/Name.visible = false
		$Control/Ability.visible = false
		$Control/Type.visible = false
		$Control/Class.visible = false
		$Control/Attack.visible = false
		$Control/HP.visible = false
		$Image.visible = false
		$Control/Rarity.visible = false
		$Base.texture = load(card_base)
		$CardIcon_Attack.visible = false
		$CardIcon_Health.visible = false
		$CardIcon_Arcane.visible = false
		$CardIcon_Gold.visible = false

	card_img = str("res://", art)
	if card_img != 'res://':
		$Image.texture = load(card_img)
	
	gold_cost = cost.count('G')
	arcane_cost = cost.count('A')

	$Control/Name.text = card_name
	#$Control/Cost.text = cost
	$Control/Gold_Cost.text = str(gold_cost)
	$Control/Arcane_Cost.text = str(arcane_cost)
	$Control/Ability.text = ability
	$Control/Class.text = card_class
	$Control/Type.text = type
	$Control/Attack.text = str(attack)
	$Control/Rarity.text = str(rarity)

	if hp == 0:
		$Control/HP.text = ''
	else:
		$Control/HP.text = str(hp)
	#$Base.get_material().set_shader_parameter("onoff", 0)

func _process(delta):
	if self.attacking:
		var direction = (target_position - position).normalized()
		position += position.direction_to(target_position) * ATTACK_SPEED * delta
		if position.distance_to(target_position) < 50:
			position = starting_position
			self.attacking = false
			self.starting_position = null
	if !self.opponent and self.location == 'play':
		attack_mod = StaticEffects.player_unit_atk_mod
		hp_mod = StaticEffects.player_unit_hp_mod
	elif self.location == 'play':
		attack_mod = StaticEffects.opponent_unit_atk_mod
		hp_mod = StaticEffects.opponent_unit_hp_mod
	
	attack = base_attack + attack_mod
	hp = base_hp + hp_mod
	if attack < 0:
		attack = 0
	if damage >= hp and self.type == 'Unit' and not self.destroyed:
		self.destroyed = true
		SignalBus._on_card_destroyed.emit(self)
		SignalBus._on_card_death.emit(self)
	if hp == 0 and self.type == "Spell":
		$Control/HP.text = ''
		$Control/Attack.text = ''
	else:
		$Control/HP.text = str(hp - damage)
		$Control/Attack.text = str(attack)
	if  self.location == 'dragged' and _can_cast():
		$Base.get_material().set_shader_parameter("onoff", 1)
		$Base.get_material().set_shader_parameter("line_color", Color(0, 0, 1, 1))
	elif self.location == 'dragged':
		$Base.get_material().set_shader_parameter("onoff", 0)
	
	if self.location == "dragged":
		$Card_Shadow.visible = true
	else:
		$Card_Shadow.visible = false
		

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var game_manager = get_parent().get_node('GameManager')
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			self.blocking = false
			if _can_cast():
				_cast_card()
			elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and self.location == 'play':
				if !UiVariables.mouse_busy and !UiVariables.select and !game_manager.opponent and self.opponent == game_manager.opponent and !self.attacked and !UiVariables.mouse_busy and game_manager.phases[game_manager.phase_index] == 'Main' and not self.menu_up:
					var menu = action_menu.instantiate()
					menu.OPTIONS = ["Attack", "Ability", "Block"]
					menu.card = self
					menu.position.y -= 32
					menu.z_index += 20
					add_child(menu)
					self.menu_up = true
					UiVariables.mouse_busy = true

				elif UiVariables.select and UiVariables.select != self and !UiVariables.select.attacked and game_manager.phases[game_manager.phase_index] == 'Main' and (UiVariables.select.opponent != self.opponent or UiVariables.select.ability_trigger == "Target"):
					SignalBus._on_card_targeted.emit(self)
				elif UiVariables.select and UiVariables.select.ability_function != 'Attack':
					SignalBus._on_card_targeted.emit(self)

		#elif event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed and !self.attacked:
			#if self.location == "play":
				#_on_chose_block(self)
func _can_cast():
	var game_manager = get_parent().get_node('GameManager')
	# Check Additional Costs
	if self.additional_costs:
		if self.additional_costs == 'Merchant':
			var count = 0
			for worker in game_manager.player_workers:
				if worker.card_mode == 'Merchant':
					count += 1
			if self.additional_costs_parameters[0] > count:
				return false
		elif self.additional_costs == 'Wizard':
			var count = 0
			for worker in game_manager.player_workers:
				if worker.card_mode == 'Wizard':
					count += 1
			if self.additional_costs_parameters[0] > count:
				return false
	if game_manager.phases[game_manager.phase_index] != 'Main' or (curr_zone and curr_zone.count_units >= 5 and self.type == "Unit"):
		return false
	if curr_zone and UiVariables.player_gold >= self.gold_cost and UiVariables.player_arcane >= self.arcane_cost and self.location in ['dragged', 'hand'] and !opponent and 'Opponent' not in curr_zone.name and game_manager.turn == 'Player' and not UiVariables.select:
		return true
	elif curr_zone and UiVariables.player_gold_opponent >= self.gold_cost and UiVariables.player_arcane_opponent >= self.arcane_cost and self.location in ['dragged', 'hand'] and opponent and 'Opponent' in curr_zone.name  and game_manager.turn == 'Opponent' and not UiVariables.select: 
		return true
	return false


func _summon_token():
	self.location = 'play'
	self.draggable = false
	$Control/Gold_Cost.visible = true
	$Control/Arcane_Cost.visible = true
	$Control/Name.visible = true
	$Control/Ability.visible = true
	$Control/Type.visible = true
	#$Control/Class.visible = true
	$Control/Attack.visible = true
	$Control/HP.visible = true
	$Image.visible = true
	#$Base.texture = card_base
	self.selectable = true
	var game_manager = get_parent().get_node('GameManager')
	var curr_zone
	
	var opp_cast_zone = get_parent().get_node('CastZone_Opponent')
	var player_cast_zone = get_parent().get_node('CastZone')
	if  game_manager.turn == 'Player':
		curr_zone = player_cast_zone
	else:
		curr_zone = opp_cast_zone
	SignalBus._on_card_casted.emit(self, player_cast_zone)
	
func _cast_card():
	$Base.get_material().set_shader_parameter("onoff", 0)
	self.rotation_degrees = 0
	var game_manager = get_parent().get_node('GameManager')
	var opp_cast_zone = get_parent().get_node('CastZone_Opponent')
	var player_cast_zone = get_parent().get_node('CastZone')

	self.z_index -= 1
	self.position = curr_zone.position
	if opponent:
		UiVariables.player_gold_opponent -= self.gold_cost
		UiVariables.player_arcane_opponent -= self.arcane_cost
	else:
		UiVariables.player_gold -= self.gold_cost
		UiVariables.player_arcane -= self.arcane_cost
		if self.additional_costs:
			print("ADD COSTS")
			if self.additional_costs == "Merchant":
				print("MERCH")
				game_manager.remove_worker("Merchant", self.additional_costs_parameters[0])
			elif self.additional_costs == "Wizard":
				print("Wizard")
				game_manager.remove_worker("Wizard", self.additional_costs_parameters[0])
	self.location = 'play'
	self.draggable = false
	$Control/Gold_Cost.visible = true
	$Control/Arcane_Cost.visible = true
	$Control/Name.visible = true
	$Control/Ability.visible = true
	$Control/Type.visible = true
	#$Control/Class.visible = true
	$Control/Attack.visible = true
	$Control/HP.visible = true
	$Image.visible = true
	#$Base.texture = card_base
	self.selectable = true
	if 'Cast' == self.ability_trigger or 'Static' == self.ability_trigger:
		var ability_scene = load('res://Abilities/' + ability_function + '.tscn')
		var ability_instance = ability_scene.instantiate()
		get_parent().add_child(ability_instance)
		ability_instance.execute([ability_parameters])
		ability_instance.queue_free()
	if 'Target' == self.ability_trigger:
		var ability_scene = load('res://Abilities/' + ability_function + '.tscn')
		var ability_instance = ability_scene.instantiate()
		get_parent().add_child(ability_instance)
		var action_target_encoding = ability_instance.TARGET_ENCODING
		var encoding_owner = action_target_encoding[0]
		var encoding_type = action_target_encoding[1]
		print("check it", action_target_encoding, game_manager.turn)
		var legal_target_available = true
		if encoding_owner == 'own' and encoding_type == 'unit':
			if game_manager.turn == 'Player' and len(player_cast_zone.units_in_zone) == 0:
				legal_target_available = false
			elif game_manager.turn == 'Opponent' and len(opp_cast_zone.units.in_zone) == 0:
				legal_target_available = false
		elif encoding_owner == 'opponent' and encoding_type == 'unit':
			if game_manager.turn == 'Player' and len(opp_cast_zone.units_in_zone) == 0:
				legal_target_available = false
			elif game_manager.turn == 'Opponent' and len(player_cast_zone.units.in_zone) == 0:
				legal_target_available = false
	SignalBus._on_card_casted.emit(self, curr_zone)
	if self.ability_trigger == 'Target':
		print('do target routine to get parameters')
		UiVariables.mouse_busy = true
		curr_target = target.instantiate()
		curr_target.line = true
		get_parent().add_child(curr_target)
		SignalBus._on_card_selected.emit(self, self.ability_function, self.ability_parameters)

func _on_card_casted(card, zone):
	if card != self:
		if self.ability_trigger == 'Trigger' and self.ability_function == 'Draw' and self.ability_parameters[1] == 'CastSpell' and self.location == 'play' and card.type == 'Spell':
			var cast = false
			if self.opponent and 'Opponent' in zone.name:
				cast = true
			elif not self.opponent and 'Opponent' not in zone.name:
				cast = true
			if cast:
				var ability_scene = load('res://Abilities/' + ability_function + '.tscn')
				var ability_instance = ability_scene.instantiate()
				get_parent().add_child(ability_instance)
				ability_instance.execute([ability_parameters[0]])
				ability_instance.queue_free()
		elif self.ability_trigger == 'Trigger' and self.ability_function == 'Damage' and self.ability_parameters[1] == 'CastSpell' and self.location == 'play' and card.type == 'Spell':
			var cast = false
			var target = null
			if self.opponent and 'Opponent' in zone.name:
				cast = true
				target = get_parent().get_node('Player_Card')
			elif not self.opponent and 'Opponent' not in zone.name:
				cast = true
				target = get_parent().get_node('Player_Card_Opponent')
			if cast:
				var ability_scene = load('res://Abilities/' + ability_function + '.tscn')
				var ability_instance = ability_scene.instantiate()
				get_parent().add_child(ability_instance)
				ability_instance.execute([self.ability_parameters[0], self, target])
				ability_instance.queue_free()

func _on_zone_area_entered(zone, area):
	if curr_zone == null and 'zone' in zone and area == self:
		curr_zone = zone
	
func _on_zone_area_exited(zone, area):
	if curr_zone == zone and area == self:
		curr_zone = null

func _area_entered(area):
	self.areas_overlapped.append(area)
	if 'selector' not in area:
		curr_area = area
	else:
		print("CARD INFO: " , self , " " , self.name , " " , self.card_id , " " , self.opponent, " ", self.location, " ")
		print("STATIC INFO: ", StaticEffects.player_unit_atk_mod, " ", StaticEffects.player_unit_hp_mod, " ", StaticEffects.opponent_unit_atk_mod, " ", StaticEffects.opponent_unit_hp_mod)
		print("ACTION INFO: ", "Attacked: ", self.attacked, " Blocking: ",  self.blocking)
		if self.location == 'hand' and not UiVariables.hover and not self.opponent and not self.attacking:
			self.position.y -= 25
			self.z_index += 1
			selected = true
			UiVariables.hover = self
			area.curr_area = self
		if self.location == 'hand' and not self.opponent:
			UiVariables.multi_hover.append(self)
			print(UiVariables.multi_hover, UiVariables.hover)

func _area_exited(area):
	self.areas_overlapped.erase(area)
	if area == curr_area:
		curr_area = null
	if 'selector' in area:
		UiVariables.multi_hover.erase(self)
	if 'selector' in area and self == UiVariables.hover:
		if self.location == 'hand':
			self.z_index -= 1
			UiVariables.hover = null
			selected = false
			if len(UiVariables.multi_hover) > 0:
				UiVariables.hover = UiVariables.multi_hover[0]
				UiVariables.hover.selected = true
				UiVariables.hover.position.y -= 25
				UiVariables.hover.z_index += 1
		print(UiVariables.multi_hover, UiVariables.hover)
		if len(UiVariables.multi_hover) == 0:
			UiVariables.hover = null

func _on_card_destroyed(card):
	if self == card:
		print("DESTROY")
		if self.location != 'view':
			await get_tree().create_timer(.9).timeout 
		if 'Static' == self.ability_trigger and card.location == 'play':
			var ability_scene = load('res://Abilities/' + ability_function + '.tscn')
			var ability_instance = ability_scene.instantiate()
			get_parent().add_child(ability_instance)
			ability_instance.end_execute([ability_parameters])
			ability_instance.queue_free()
		if damage >= hp and self.type == 'Unit' or card.location == 'hand':
			SignalBus._on_send_to_grave.emit(self.card_id, self.opponent)
		self.queue_free()

func _on_card_death(card):
	if self != card and self.ability_trigger == "Trigger" and self.ability_function == "Gold" and self.location == 'play':
		var ability_scene = load('res://Abilities/' + ability_function + '.tscn')
		var ability_instance = ability_scene.instantiate()
		get_parent().add_child(ability_instance)
		ability_instance.execute([self.ability_parameters])


func _on_card_targeted(target):
	if target != self:
		return
	#SignalBus._on_action_sent_to_queue.emit([action, target, input])

func _on_card_selected(card, action, parameters):
	if card == self:
		$Base.get_material().set_shader_parameter("onoff", 1)
		$Base.get_material().set_shader_parameter("line_color", Color(0, 1, 0, 1))
		
func _on_card_deselected(card):
	if card == self:
		$Base.get_material().set_shader_parameter("onoff", 0)

func _on_turn_changed():
	self.attacked = false
	var game_manager = get_parent().get_node('GameManager')
	if game_manager != null and self.location == 'play' and (game_manager.turn == "Player" and not self.opponent or game_manager.turn == "Opponent" and self.opponent):
		self.blocking = false
		$Base.get_material().set_shader_parameter("onoff", 0)

func _on_chose_attack(card):
	if card == self:
		print(self, 'is attacking')
		UiVariables.mouse_busy = true
		curr_target = target.instantiate()
		curr_target.line = true
		get_parent().add_child(curr_target)
		SignalBus._on_card_selected.emit(self, 'Attack', self.attack)

func _on_chose_block(card):
	if card == self:
		print(self, 'is blocking')
		$Base.get_material().set_shader_parameter("onoff", 1)
		$Base.get_material().set_shader_parameter("line_color", Color(1, 1, 1, 1))
		self.blocking = true
		self.attacked = true
		UiVariables.mouse_busy = false

func _on_chose_ability(card):
	if card == self and ability_trigger == 'Select':
		print(self, 'is using ability: ', ability)
		var game_manager = get_parent().get_node('GameManager')
		var opp_cast_zone = get_parent().get_node('CastZone_Opponent')
		var player_cast_zone = get_parent().get_node('CastZone')
		var ability_scene = load('res://Abilities/' + ability_function + '.tscn')
		var ability_instance = ability_scene.instantiate()
		if ability_function == "Damage":
			var action_target_encoding = ability_instance.TARGET_ENCODING
			var encoding_owner = action_target_encoding[0]
			var encoding_type = action_target_encoding[1]
			print("check it", action_target_encoding, game_manager.turn)
			var legal_target_available = true
			if encoding_owner == 'own' and encoding_type == 'unit':
				if game_manager.turn == 'Player' and len(player_cast_zone.units_in_zone) == 0:
					legal_target_available = false
				elif game_manager.turn == 'Opponent' and len(opp_cast_zone.units.in_zone) == 0:
					legal_target_available = false
			elif encoding_owner == 'opponent' and encoding_type == 'unit':
				if game_manager.turn == 'Player' and len(opp_cast_zone.units_in_zone) == 0:
					legal_target_available = false
				elif game_manager.turn == 'Opponent' and len(player_cast_zone.units.in_zone) == 0:
					legal_target_available = false
					print('do target routine to get parameters')
			UiVariables.mouse_busy = true
			curr_target = target.instantiate()
			curr_target.line = true
			get_parent().add_child(curr_target)
			SignalBus._on_card_selected.emit(self, self.ability_function, self.ability_parameters)
		else:
			get_parent().add_child(ability_instance)
			ability_instance.execute([ability_parameters])
			ability_instance.queue_free()
		self.attacked = true
		
func _after_damage_dealt(damage, source, target):
	if source == self:
		if self.ability_function == 'Thieve':
			var curr_scene = thieve_scene.instantiate()
			get_parent().add_child(curr_scene)
			curr_scene.execute([self.ability_parameters, target])
