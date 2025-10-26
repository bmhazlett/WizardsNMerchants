extends Button

var pack_is_open
# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_on_button_pressed)
	var pack_is_open = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _get_random_card(rarity):
	var filtered = []
	for card in CardDB.CARD_DB:
		var data = CardDB.CARD_DB[card]
		if data['Rarity'] == rarity:
			filtered.append(card)
	return filtered[randi() % len(filtered)]
	
	
func _on_button_pressed():
	if GameVariables.player_money > 0 and not pack_is_open:
		pack_is_open = true
		GameVariables.player_money -= 5
		var cards_to_add = []
		# Get 4 Commons
		for i in range(0, 4):
			cards_to_add.append(_get_random_card('C'))
		# Get 2 Uncommons
		for i in range(0, 2):
			cards_to_add.append(_get_random_card('U'))
		# Get 1 Rare
		cards_to_add.append(_get_random_card('R'))
		for i in range(len(cards_to_add)):
			var card = cards_to_add[i]
			var collection_card = load('res://Cards/' + 'CardBase' + '.tscn')
			var collection_instance = collection_card.instantiate()
			collection_instance.position.x = i * 70
			collection_instance.position.y -= 50
			collection_instance.card_id = card
			add_child(collection_instance)
			print(card)
			if card in Collection.collection:
				Collection.collection[card] += 1
			else:
				Collection.collection[card] = 1
			print(Collection.collection)
	elif pack_is_open:
		pack_is_open = false
		for n in get_children():
			self.remove_child(n)
			n.queue_free()

		
		
		
