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
var location = 'hand'
var action = 'none'
var draggable = false

func _ready():
	card_id = 'Knight'
	card_name = CardDB.PLAYER_CARD_DB[card_id]['Name']
	cost = ''
	ability = ''
	card_class = ''
	type =  CardDB.PLAYER_CARD_DB[card_id]['Type']
	attack = '0'
	hp = int(CardDB.PLAYER_CARD_DB[card_id]['HP'])
	art = 'to be implemented'
	
	SignalBus._on_card_destroyed.connect(_card_destroyed)
	SignalBus._on_card_targeted.connect(_on_card_targeted)

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
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
				if !UiVariables.select:
					SignalBus._on_card_selected.emit(self)
				elif UiVariables.select != self:
					SignalBus._on_card_targeted.emit(self)
					SignalBus._on_card_deselected.emit()

		elif event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed:
			SignalBus._on_card_destroyed.emit(self)

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
