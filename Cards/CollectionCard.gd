extends CardBase

var curr_deck_count = 0
var collection_count = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	collection_count = 	Collection.collection[self.card_id]
	if self.card_id in Collection.curr_deck:
		curr_deck_count = Collection.curr_deck[self.card_id]
		print(collection_count)
	$Amount/Quantity.text = str(curr_deck_count) + ' / ' + str(collection_count)
	if self.type == 'Spell':
		$Control/Attack.visible = false
		$Control/HP.visible = false
		$CardIcon_Health.visible = false
		$CardIcon_Attack.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.card_id in Collection.curr_deck:
		self.curr_deck_count = Collection.curr_deck[self.card_id]
	else:
		self.curr_deck_count = 0
	$Amount/Quantity.text = str(curr_deck_count) + ' / ' + str(collection_count)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and !event.pressed and self.curr_deck_count < self.collection_count and Collection._get_curr_deck_size() < GameVariables.max_deck_size and curr_deck_count < GameVariables.max_num_cards_in_deck and (self.card_class[0] == Collection.curr_class[0] or self.card_class == 'Gen'):
		print('add', self.card_id)
		if self.card_id in Collection.curr_deck:
			Collection.curr_deck[card_id] += 1
		else:
			Collection.curr_deck[card_id] = 1
		SignalBus._on_card_added_to_deck.emit(self.card_id)
		print(Collection.curr_deck)
