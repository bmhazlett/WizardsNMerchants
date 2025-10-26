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
var type =  'player'
var attack = ''
var hp = ''
var base_hp = 0
var hp_mod = 0
var damage = 0
var art = 'to be implemented'
var card_mode = ''
var location = 'hand'
var action = 'none'
var draggable = false
var opponent = false
var attacked = false
var selectable = true
var blocking = false

func _ready():
	if 'Opponent' in self.name:
		opponent = true

	if self.opponent:
		if GameVariables.opponent == "1":
			card_id = GameVariables.opp_one_class
		elif GameVariables.opponent == "2":
			card_id = GameVariables.opp_two_class
		elif GameVariables.opponent == "3":
			card_id = GameVariables.opp_three_class
		else:
			card_id = GameVariables.opp_one_class
	else:
		card_id = Collection.curr_class
	card_name = CardDB.PLAYER_CARD_DB[card_id]['Name']
	cost = ''
	ability = ''
	card_class = ''
	#type =  CardDB.PLAYER_CARD_DB[card_id]['Type']
	attack = '0'
	hp = int(CardDB.PLAYER_CARD_DB[card_id]['HP'])
	base_hp = hp
	art = CardDB.PLAYER_CARD_DB[card_id]['Art']
	
	SignalBus._on_card_destroyed.connect(_card_destroyed)
	SignalBus._on_card_targeted.connect(_on_card_targeted)
	SignalBus._on_card_selected.connect(_on_card_selected)
	SignalBus._on_card_deselected.connect(_on_card_deselected)
	
	$Control/Name.text = card_name
	$Control/Cost.text = cost
	$Control/Ability.text = ability
	$Control/HP.text = str(hp)
	#$Base.get_material().set_shader_parameter("onoff", 0)
		
	var card_img = str("res://", art)
	if card_img != 'res://':
		$Image.texture = load(card_img)
		#$Image.scale *= $Base.texture.get_size()/$Image.texture.get_size()/1.3
		#$Image.scale.y /= 1.7
		#$Image.scale *= 16
		#$Image.position.y -= 50

func _process(delta):
	hp = base_hp + hp_mod
	if damage >= hp:
		SignalBus._on_card_destroyed.emit(self)
	$Control/HP.text = str(hp - damage)
	

func _input_event(viewport, event, shape_idx):
	var game_manager = get_parent().get_node('GameManager')
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
				if !UiVariables.mouse_busy and !UiVariables.select and self.opponent == game_manager.opponent and !self.attacked and game_manager.phases[game_manager.phase_index] == 'Main':
					UiVariables.mouse_busy = true
					SignalBus._on_card_selected.emit(self, "Attack")
				elif UiVariables.select and UiVariables.select != self and !UiVariables.select.attacked and game_manager.phases[game_manager.phase_index] == 'Main' and UiVariables.select.opponent != self.opponent:
					print('Target', UiVariables.select)
					SignalBus._on_card_targeted.emit(self)
					#SignalBus._on_card_deselected.emit(UiVariables.select)
					#SignalBus._on_card_deselected.emit(self)
					#UiVariables.mouse_busy = false
				elif UiVariables.select and UiVariables.select.ability_function != 'Attack':
					SignalBus._on_card_targeted.emit(self)

		elif event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed:
			SignalBus._on_card_destroyed.emit(self)

func _card_destroyed(card):
	if self == card:
		if self.opponent:
			SignalBus._on_game_end.emit("player")
		else:
			SignalBus._on_game_end.emit("opponent")
		#self.queue_free()
		
func _on_card_targeted(card):
	return

func _on_card_selected(card):
	if card == self:
		$Base.get_material().set_shader_parameter("onoff", 1)
		
func _on_card_deselected():
	$Base.get_material().set_shader_parameter("onoff", 0)
	
func is_legal(source):
	print(source)
	return true
