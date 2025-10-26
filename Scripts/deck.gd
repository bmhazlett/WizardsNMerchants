extends Area2D

var card = preload("res://Cards/UnitCard.tscn")
var horizontal_card_viewer_scene = preload("res://Scenes/horizonal_card_viewer.tscn")
var opponent = false
var cards_in_deck = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var deck_to_use
	if 'Opponent' in self.name:
		opponent = true
		if GameVariables.opponent == "1":
			deck_to_use = Collection.first_opp_deck
		elif GameVariables.opponent == "2":
			deck_to_use = Collection.second_opp_deck
		elif GameVariables.opponent == "3":
			deck_to_use = Collection.third_opp_deck
		else:
			deck_to_use = Collection.first_opp_deck
	else:
		deck_to_use = Collection.curr_deck
	for card in deck_to_use:
		print(card)
		for count in deck_to_use[card]:
			cards_in_deck.append(card)
	print(cards_in_deck)
	cards_in_deck.shuffle()
	
	SignalBus._draw_card.connect(_draw_card)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _draw_card(turn, source):
	if (turn == 'Opponent' and opponent) or (turn != 'Opponent' and !opponent):
		SignalBus._on_card_draw.emit(turn, self, source)
		
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			print("GRAVE: ", cards_in_deck)
			var horizontal_card_viewer = horizontal_card_viewer_scene.instantiate()
			horizontal_card_viewer.cards = cards_in_deck
			horizontal_card_viewer.deck = true
			horizontal_card_viewer.position.x = 100
			horizontal_card_viewer.position.y = 100
			get_parent().add_child(horizontal_card_viewer)
			get_tree().paused = true
