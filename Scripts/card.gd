extends Area2D

var dragging = false
var curr_zone = null

var start_x = 576;
var start_y = 573;
var card_id = '';
var curr_area = null
var card_name = ''
var cost = ''
var ability = ''
var card_class = ''
var type =  ''
var attack = ''
var hp = ''
var art = 'to be implemented'
var card_mode = ''
var gold_cost = cost.count('G')
var arcane_cost = cost.count('A')
var location = 'hand'
var action = 'none'
var draggable = true
var opponent = false

func _ready():
	if card_id != 'Worker':
		card_name = CardDB.CARD_DB[card_id]['Name']
		cost = CardDB.CARD_DB[card_id]['Cost']
		ability = CardDB.CARD_DB[card_id]['Ability']
		card_class = CardDB.CARD_DB[card_id]['Class']
		type =  CardDB.CARD_DB[card_id]['Type']
		attack = CardDB.CARD_DB[card_id]['Attack']
		hp = int(CardDB.CARD_DB[card_id]['HP'])
		art = 'to be implemented'
	else:
		card_name = CardDB.WORKER_CARD_DB[card_id]['Name']
		cost = CardDB.WORKER_CARD_DB[card_id]['Cost']
		ability = CardDB.WORKER_CARD_DB[card_id]['Ability']
		card_class = CardDB.WORKER_CARD_DB[card_id]['Class']
		type =  CardDB.WORKER_CARD_DB[card_id]['Type']
		attack = CardDB.WORKER_CARD_DB[card_id]['Attack']
		hp = int(CardDB.WORKER_CARD_DB[card_id]['HP'])
		art = 'to be implemented'	
	
	
	gold_cost = cost.count('G')
	arcane_cost = cost.count('A')
	
	if card_id == 'Worker':
		card_mode = 'Merchant'
		card_name = 'Merchant'
	
	self.area_entered.connect(_area_entered)
	self.area_exited.connect(_area_exited)
	SignalBus._on_card_destroyed.connect(_card_destroyed)
	SignalBus._on_zone_area_entered.connect(self._on_zone_area_entered)
	SignalBus._on_zone_area_exited.connect(self._on_zone_area_exited)
	if opponent and card_id != 'Worker':
		SignalBus._on_card_added_to_opponent_hand.emit(self)
	elif card_id != 'Worker':
		SignalBus._on_card_added_to_hand.emit(self)

	if card_id == 'Worker' and opponent:
		self.position = Vector2(150, 150)
	if card_id == 'Worker' and !opponent:
		self.position = Vector2(150, 750)
		
	SignalBus._on_card_targeted.connect(_on_card_targeted)
	SignalBus._on_card_selected.connect(_on_card_selected)
	SignalBus._on_card_deselected.connect(_on_card_deselected)

	$Control/VBoxContainer/HBoxContainer/Name.text = card_name
	$Control/VBoxContainer/HBoxContainer/Cost.text = cost
	$Control/VBoxContainer/HBoxContainer3/Ability.text = ability
	$Control/VBoxContainer/HBoxContainer2/Class.text = card_class
	$Control/VBoxContainer/HBoxContainer2/Type.text = type
	$Control/VBoxContainer/HBoxContainer4/Attack.text = attack
	$Control/VBoxContainer/HBoxContainer4/HP.text = str(hp)
	$Sprite2D.get_material().set_shader_parameter("onoff", 0)

func _process(delta):
	$Control/VBoxContainer/HBoxContainer4/HP.text = str(hp)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var game_manager = get_parent().get_node('GameManager')
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			if curr_area and UiVariables.player_gold >= self.gold_cost and UiVariables.player_arcane >= self.arcane_cost and self.action != 'cast' and !opponent and 'Opponent' not in curr_area.name and 'Worker' not in curr_area.name:
				_cast_card()
			elif curr_area and UiVariables.player_gold_opponent >= self.gold_cost and UiVariables.player_arcane_opponent >= self.arcane_cost and self.action != 'cast' and opponent and 'Opponent' in curr_area.name and  'Worker' not in curr_area.name:
				_cast_card()
			elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and self.action == 'cast':
				if !UiVariables.select:
					SignalBus._on_card_selected.emit(self)
				elif UiVariables.select != self and game_manager.phases[game_manager.phase_index] == 'Main' and self.card_id != 'Worker':
					SignalBus._on_card_targeted.emit(self)
					SignalBus._on_card_deselected.emit()

		elif event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed and self.card_id == 'Worker' and game_manager.phases[game_manager.phase_index] == 'Assign':
			if self.card_mode == 'Merchant':
				self.card_mode = 'Wizard'
				self.card_name = 'Wizard'
			elif self.card_mode == 'Wizard':
				self.card_mode = 'Merchant'
				self.card_name = 'Merchant'
			$Control/VBoxContainer/HBoxContainer/Name.text = self.card_name

func _cast_card():
	var game_manager = get_parent().get_node('GameManager')
	if game_manager.phases[game_manager.phase_index] != 'Main':
		return
	self.position = curr_area.position
	if opponent:
		UiVariables.player_gold_opponent -= self.gold_cost
		UiVariables.player_arcane_opponent -= self.arcane_cost
	else:
		UiVariables.player_gold -= self.gold_cost
		UiVariables.player_arcane -= self.arcane_cost
	self.location = 'zone'
	self.draggable = false
	self.action = 'cast'
	SignalBus._on_card_casted.emit(self, curr_zone)
	
func _on_zone_area_entered(area):
	curr_zone = area
	
func _on_zone_area_exited(area):
	if curr_zone == area:
		curr_zone = null

func _area_entered(area):
	if 'selector' not in area:
		curr_area = area

func _area_exited(area):
	if area == curr_area:
		curr_area = null

func _card_destroyed(card):
	if self == card:
		self.queue_free()
		
func _on_card_targeted(card):
	if self == card:
		self.hp -= int(UiVariables.select.attack)
		UiVariables.select.hp -= int(self.attack)
		if self.hp <= 0:
			SignalBus._on_card_destroyed.emit(self)
		if UiVariables.select.hp <= 0:
			SignalBus._on_card_destroyed.emit(UiVariables.select)

func _on_card_selected(card):
	if card == self:
		$Sprite2D.get_material().set_shader_parameter("onoff", 1)
		
func _on_card_deselected():
	$Sprite2D.get_material().set_shader_parameter("onoff", 0)
