extends Button

var card_name = ""
var quantity = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_on_button_pressed)
	SignalBus._on_class_changed.connect(_on_class_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_label(card_name, quantity):
	self.card_name = card_name
	self.quantity = int(quantity)
	$CardEntry/CardName.text = self.card_name
	$CardEntry/Quantity.text = str(self.quantity)

func increment_quantity():
	self.quantity += 1
	$CardEntry/Quantity.text = str(self.quantity)

func decrement_quantity():
	self.quantity -= 1
	$CardEntry/Quantity.text = str(self.quantity)
	
func print_label():
	print($CardEntry/CardName.text, $CardEntry/Quantity.text)

func _remove_card():
	print('Remove', self.card_name)
	if self.card_name not in Collection.curr_deck:
		return
	Collection.curr_deck[self.card_name] -= 1
	print(Collection.curr_deck)
	if Collection.curr_deck[self.card_name] == 0:
		Collection.curr_deck.erase(self.card_name)
		SignalBus._on_card_removed_from_deck.emit(self.card_name, true)
		self.queue_free()
	else:
		self.decrement_quantity()
		SignalBus._on_card_removed_from_deck.emit(self.card_name, false)

func _on_button_pressed():
	_remove_card()
		
func _on_class_changed():
	print("CLASS CHANGE ", self.card_name)
	var card_class
	if card_name in CardDB.CARD_DB:
		card_class = CardDB.CARD_DB[card_name]['Class']
	if card_class and card_class != Collection.curr_class[0] and card_class != 'Gen':
		var quant = self.quantity
		for i in range(quant):
			print(i)
			_remove_card()
