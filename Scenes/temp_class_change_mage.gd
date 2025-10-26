extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_on_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_button_pressed():
	print("MAGE")
	Collection.curr_class = 'Mage'
	if Collection.curr_deck_name == 'deck1':
		Collection.deck1_class = 'Mage'
	else:
		Collection.deck2_class = 'Mage'
	SignalBus._on_class_changed.emit()
