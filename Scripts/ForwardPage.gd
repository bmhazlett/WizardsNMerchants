extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_on_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	print("Forward")
	SignalBus._on_collection_page_forward.emit()

