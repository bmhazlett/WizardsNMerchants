extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_on_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	if GameVariables.player_money > 0:
		GameVariables.player_money -= 1
		var size = CardDB.CARD_DB.size()
		var random_key = CardDB.CARD_DB.keys()[randi() % size]
		print(random_key)
		if random_key in Collection.collection:
			Collection.collection[random_key] += 1
		else:
			Collection.collection[random_key] = 1
		print(Collection.collection)
		
