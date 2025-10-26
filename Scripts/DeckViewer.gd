extends VBoxContainer
var deck_card = preload("res://Scenes/DeckCard.tscn")
var deck_display = []
var start = false
var deck = ''

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus._on_card_added_to_deck.connect(card_added_to_deck)
	SignalBus._on_card_removed_from_deck.connect(card_removed_from_deck)
	if self.get_parent().name == 'Deck1':
		deck = Collection.deck1
	elif self.get_parent().name == 'Deck2':
		deck = Collection.deck2
	else:
		deck = Collection.deck1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not start:
		var instance
		for key in deck:
			instance = deck_card.instantiate()
			add_child(instance)
			instance.set_label(key, str(deck[key]))
			deck_display.append(instance)
		start = true
	var card_count = find_child('CardCount')
	card_count.text = "Cards in Deck " + str(_get_deck_size())


func _get_deck_size():
	var size = 0
	for card in deck_display:
		if  'quantity' in card:
			size += card.quantity
	return size

func card_added_to_deck(card_id):
	print(self.get_parent().name, " ", Collection.curr_deck_name)
	if (self.get_parent().name == 'Deck1' and Collection.curr_deck_name == 'deck2') or (self.get_parent().name == 'Deck2' and Collection.curr_deck_name == 'deck1'):
		return false
	
	if self._get_deck_size() >= GameVariables.max_deck_size:
		print('thats a too many cards bucko')
		return false
	var found = false
	for card in deck_display:
		print(card)
		if card.card_name == card_id:
			card.increment_quantity()
			found = true
			break
			
	if not found:
		var instance = deck_card.instantiate()
		add_child(instance)
		instance.set_label(card_id, "1")
		deck_display.append(instance)
		
func card_removed_from_deck(card_id, remove):
	if self.get_parent().name == 'Deck1' and Collection.curr_deck_name == 'deck2' or self.get_parent().name == 'Deck2' and Collection.curr_deck_name == 'deck1':
		return false
		
	var found = false
	var i = 0
	while i < len(deck_display):
		var card = deck_display[i]
		if card.card_name == card_id and remove:
			deck_display.remove_at(i)
			break
		i += 1
