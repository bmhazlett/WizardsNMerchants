extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_on_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_button_pressed():
	print("Rogue")
	Collection.curr_class = 'Rogue'
	if Collection.curr_deck_name == 'deck1':
		Collection.deck1_class = 'Rogue'
	else:
		Collection.deck2_class = 'Rogue'
	SignalBus._on_class_changed.emit()
