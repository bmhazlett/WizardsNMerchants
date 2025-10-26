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
var art = ''
var card_mode = ''
var gold_cost = cost.count('G')
var arcane_cost = cost.count('A')
var location = 'hand'
var action = 'none'
var draggable = true
var opponent = false
var target_line = preload("res://Scenes/target_line.tscn")
var curr_line = null
var attacked = false
var selectable = false
var selected = false


func _ready():
	print(card_name)
	if card_id != 'Worker':
		card_name = CardDB.CARD_DB[card_id]['Name']
		cost = CardDB.CARD_DB[card_id]['Cost']
		ability = CardDB.CARD_DB[card_id]['Ability']
		card_class = CardDB.CARD_DB[card_id]['Class']
		type =  CardDB.CARD_DB[card_id]['Type']
		attack = CardDB.CARD_DB[card_id]['Attack']
		hp = int(CardDB.CARD_DB[card_id]['HP'])
		art = CardDB.CARD_DB[card_id]['Art']
	else:
		if !card_name:
			card_name = CardDB.WORKER_CARD_DB[card_id]['Name']
		cost = CardDB.WORKER_CARD_DB[card_id]['Cost']
		if !ability:
			ability = CardDB.WORKER_CARD_DB[card_id]['Ability']
		card_class = CardDB.WORKER_CARD_DB[card_id]['Class']
		type =  CardDB.WORKER_CARD_DB[card_id]['Type']
		attack = CardDB.WORKER_CARD_DB[card_id]['Attack']
		hp = int(CardDB.WORKER_CARD_DB[card_id]['HP'])
		if !art:
			art = CardDB.WORKER_CARD_DB[card_id]['Art']
		if location != 'view':
			self.scale = Vector2(1.3, 1.3)
	
	
	var card_img = str("res://", art)
	if card_img != 'res://':
		$Image.texture = load(card_img)
		print($Image.texture)
		$Image.scale *= $Base.texture.get_size()/$Image.texture.get_size()/2/1.3
		$Image.scale.y /= 1.7
		$Image.position.y -= 25
		print($Image.scale)
	gold_cost = cost.count('G')
	arcane_cost = cost.count('A')
	
	if card_id == 'Worker' and card_name != 'Wizard':
		card_mode = 'Merchant'
		card_name = 'Merchant'
	
	self.area_entered.connect(_area_entered)
	self.area_exited.connect(_area_exited)
	SignalBus._on_card_destroyed.connect(_card_destroyed)
	SignalBus._on_zone_area_entered.connect(self._on_zone_area_entered)
	SignalBus._on_zone_area_exited.connect(self._on_zone_area_exited)
	SignalBus._on_turn_changed.connect(self._on_turn_changed)
	if opponent and card_id != 'Worker':
		SignalBus._on_card_added_to_opponent_hand.emit(self)
	elif card_id != 'Worker':
		SignalBus._on_card_added_to_hand.emit(self)

	SignalBus._on_card_targeted.connect(_on_card_targeted)
	SignalBus._on_card_selected.connect(_on_card_selected)
	SignalBus._on_card_deselected.connect(_on_card_deselected)
	
	$Control/Name.text = card_name
	$Control/Cost.text = cost
	$Control/Ability.text = ability
	$Control/Class.text = card_class
	$Control/Type.text = type
	$Control/Attack.text = attack

	if hp == 0:
		$Control/HP.text = ''
	else:
		$Control/HP.text = str(hp)
	$Base.get_material().set_shader_parameter("onoff", 0)

func _process(delta):
	if hp == 0:
		$Control/HP.text = ''
	else:
		$Control/HP.text = str(hp)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var game_manager = get_parent().get_node('GameManager')
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and self.card_id != 'Worker':
			if curr_zone and UiVariables.player_gold >= self.gold_cost and UiVariables.player_arcane >= self.arcane_cost and self.action != 'cast' and !opponent and 'Opponent' not in curr_zone.name and 'cards_in_zone' in curr_zone and curr_zone.count_units < 5 and game_manager.turn == 'Player':
				_cast_card()
			elif curr_zone and UiVariables.player_gold_opponent >= self.gold_cost and UiVariables.player_arcane_opponent >= self.arcane_cost and self.action != 'cast' and opponent and 'Opponent' in curr_zone.name and curr_zone.count_units < 5 and game_manager.turn == 'Opponent': 
				_cast_card()
			elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and self.action == 'cast':
				if !UiVariables.select and self.opponent == game_manager.opponent and !self.attacked and !UiVariables.mouse_busy and game_manager.phases[game_manager.phase_index] == 'Main':
					UiVariables.mouse_busy = true
					curr_line = target_line.instantiate()
					get_parent().add_child(curr_line)
					SignalBus._on_card_selected.emit(self)
				elif UiVariables.select and UiVariables.select != self and !UiVariables.select.attacked and game_manager.phases[game_manager.phase_index] == 'Main':
					SignalBus._on_card_targeted.emit(self)
					SignalBus._on_card_deselected.emit()
					curr_line = null
					UiVariables.mouse_busy = false

		elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and self.card_id == 'Worker' and game_manager.phases[game_manager.phase_index] == 'Assign':
			if self.card_mode == 'Merchant':
				self.card_mode = 'Wizard'
				self.card_name = 'Wizard'
				self.ability = 'Produce 1 Arcane'
				art = 'Sprites/Wizard.png'
			elif self.card_mode == 'Wizard':
				self.card_mode = 'Merchant'
				self.card_name = 'Merchant'
				self.ability = 'Produce 1 Gold'
				art = 'Sprites/Merchant.png'

			var card_img = str("res://", art)
			if card_img != 'res://':
				$Image.texture = load(card_img)
			$Control/Name.text = self.card_name
			$Control/Ability.text = self.ability

func _cast_card():
	self.scale /= 1.25
	self.z_index -= 1
	var game_manager = get_parent().get_node('GameManager')
	if game_manager.phases[game_manager.phase_index] != 'Main':
		return
	self.position = curr_zone.position
	if opponent:
		UiVariables.player_gold_opponent -= self.gold_cost
		UiVariables.player_arcane_opponent -= self.arcane_cost
	else:
		UiVariables.player_gold -= self.gold_cost
		UiVariables.player_arcane -= self.arcane_cost
	self.location = 'zone'
	self.draggable = false
	self.action = 'cast'
	$Image.scale = $Base.texture.get_size()/$Image.texture.get_size()/2.3
	$Image.position.y += 25
	$Control/Cost.visible = false
	$Control/Name.visible = false
	$Control/Ability.visible = false
	$Control/Type.visible = false
	$Control/Class.visible = false
	self.selectable = true
	SignalBus._on_card_casted.emit(self, curr_zone)
	
func _on_zone_area_entered(area):
	curr_zone = area
	
func _on_zone_area_exited(area):
	if curr_zone == area:
		curr_zone = null

func _area_entered(area):
	if 'selector' not in area:
		curr_area = area
	else:
		if self.location == 'hand':
			self.scale *= 1.25
			self.position.y -= 50
		selected = true

func _area_exited(area):
	if area == curr_area:
		curr_area = null
	if 'selector' in area:
		if self.location == 'hand':
			self.scale /= 1.25
		selected = false

func _card_destroyed(card):
	if self == card:
		self.queue_free()
		
func _on_card_targeted(source, target):
	if self == target and self.opponent != UiVariables.select.opponent:
		UiVariables.select.attacked = true
		self.hp -= int(UiVariables.select.attack)
		UiVariables.select.hp -= int(self.attack)
		if self.hp <= 0:
			SignalBus._on_card_destroyed.emit(self)
		if UiVariables.select.hp <= 0:
			SignalBus._on_card_destroyed.emit(UiVariables.select)

func _on_card_selected(card):
	if card == self:
		$Base.get_material().set_shader_parameter("onoff", 1)
		
func _on_card_deselected():
	$Base.get_material().set_shader_parameter("onoff", 0)

func _on_turn_changed():
	attacked = false
