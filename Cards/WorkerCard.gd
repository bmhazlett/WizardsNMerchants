extends CardBase

# Called when the node enters the scene tree for the first time. 
func _ready():
	var card_id = 'Worker'
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
	var card_img = str("res://", art)
	if card_img != 'res://':
		$Image.texture = load(card_img)

	card_mode = 'Merchant'
	card_name = 'Merchant'
	$Control/Name.text = card_name
	#$Control/Cost.text = cost
	$Control/Ability.text = ability
	$Control/Class.text = card_class
	$Control/Type.text = type
	$Control/Attack.text = attack
	SignalBus._on_card_destroyed.connect(_on_card_destroyed)
	if hp == 0:
		$Control/HP.text = ''
	else:
		$Control/HP.text = str(hp)
	$Base.get_material().set_shader_parameter("onoff", 0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func swap():
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

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var game_manager = get_parent().get_node('GameManager')
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and self.card_id == 'Worker' and game_manager.phases[game_manager.phase_index] == 'Assign' and game_manager.turn == 'Player':
			print(opponent, game_manager.turn)
			self.swap()
