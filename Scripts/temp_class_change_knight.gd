extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_on_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_button_pressed():
	print("KNIGHT")
	Collection.curr_class = 'Knight'
	if Collection.curr_deck_name == 'deck1':
		Collection.deck1_class = 'Knight'
	else:
		Collection.deck2_class = 'Knight'
	SignalBus._on_class_changed.emit()
