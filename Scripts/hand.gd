extends Node2D

var cards_in_hand = []
var opponent = false

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus._on_card_added_to_hand.connect(_on_card_added_to_hand)
	SignalBus._on_card_added_to_opponent_hand.connect(_on_card_added_to_opponent_hand)
	SignalBus._on_card_casted.connect(_on_card_casted)
	SignalBus._on_card_destroyed.connect(_on_card_destroyed)
	if 'Opponent' in self.name:
		opponent = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_hand()

func update_hand():
	var i = 0
	while i < len(cards_in_hand):
		if cards_in_hand[i].location == 'hand':
			cards_in_hand[i].position = Vector2(self.position.x + i * 85, self.position.y)
		i += 1

func _on_card_added_to_hand(card):
	if opponent:
		return
	cards_in_hand.append(card)


func _on_card_added_to_opponent_hand(card):
	if not opponent:
		return
	cards_in_hand.append(card)


func _on_card_casted(card, curr_area):
	var found = false
	var i = 0
	while i < len(cards_in_hand):
		if card == cards_in_hand[i]:
			found = true
			break 
		i += 1
	if found:
		cards_in_hand.remove_at(i)


func _on_card_destroyed(card):
	var found = false
	var i = 0
	while i < len(cards_in_hand):
		if card == cards_in_hand[i]:
			found = true
			break 
		i += 1
	if found:
		cards_in_hand.remove_at(i)
