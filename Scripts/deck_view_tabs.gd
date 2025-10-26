extends TabContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	if Collection.curr_deck_name == 'deck1':
		set_current_tab(0)
	elif Collection.curr_deck_name == 'deck2':
		set_current_tab(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_current_tab_control().name == 'Deck1':
		Collection.curr_deck = Collection.deck1
		Collection.curr_deck_name = 'deck1'
		Collection.curr_class = Collection.deck1_class
	elif get_current_tab_control().name == 'Deck2':
		Collection.curr_deck = Collection.deck2
		Collection.curr_deck_name = 'deck2'
		Collection.curr_class = Collection.deck2_class
	#print(Collection.curr_deck, Collection.curr_class, Collection.curr_deck_name)
