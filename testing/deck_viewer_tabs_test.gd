extends TabContainer


var deck_view = preload("res://Scenes/deck_view.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for deck in Collection.player_decks:
		var deck_name = deck['Name']
		var deck_class = deck['Class']
		var deck_cards = deck['Cards']
		var new_vbox = VBoxContainer.new()
		new_vbox.name = deck_name
		add_child(new_vbox)
		var new_deck_view = deck_view.instantiate()
		new_vbox.add_child(new_deck_view)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	return
	if get_current_tab_control().name == 'Deck1':
		Collection.curr_deck = Collection.deck1
		Collection.curr_deck_name = 'deck1'
		Collection.curr_class = Collection.deck1_class
	elif get_current_tab_control().name == 'Deck2':
		Collection.curr_deck = Collection.deck2
		Collection.curr_deck_name = 'deck2'
		Collection.curr_class = Collection.deck2_class
	#print(Collection.curr_deck, Collection.curr_class, Collection.curr_deck_name)
