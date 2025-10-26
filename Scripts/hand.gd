extends Node2D

var cards_in_hand = []
var opponent = false
const MAX_HAND_SIZE = 7
@export var test_curve: Curve

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
	update_hand(delta)

func update_hand(delta):
	var i = 0
	while i < len(cards_in_hand):
		if cards_in_hand[i].location != 'hand':
			pass
		else:
			if cards_in_hand[i].selected:
				i += 1
				continue
				
			var target_position;
			var speed = 350;

			if not cards_in_hand[i].selected:
				target_position = Vector2(self.position.x + i * 32, self.position.y)
			if i < len(cards_in_hand) - 1 and cards_in_hand[i+1].selected:
				target_position = Vector2(target_position.x - 6, self.position.y)
			if i < len(cards_in_hand) - 2 and cards_in_hand[i+2].selected:
				target_position = Vector2(target_position.x - 12, self.position.y)
			if i > 0 and cards_in_hand[i-1].selected:
				target_position = Vector2(target_position.x + 6, self.position.y)
			if i > 1 and cards_in_hand[i-2].selected:
				target_position = Vector2(target_position.x + 12, self.position.y)
			
			var distance_to_target = cards_in_hand[i].position.distance_to(target_position)
			if distance_to_target < 5:
				cards_in_hand[i].position = target_position
			else:
				var direction = (target_position - cards_in_hand[i].position).normalized()
				cards_in_hand[i].position += cards_in_hand[i].position.direction_to(target_position) * (speed * 1) * delta

		i += 1

func _on_card_added_to_hand(card):
	if opponent:
		return
	if len(cards_in_hand) == MAX_HAND_SIZE:
		SignalBus._on_card_destroyed.emit(card)
	else:
		cards_in_hand.append(card)

func _on_card_added_to_opponent_hand(card):
	if not opponent:
		return
	if len(cards_in_hand) == MAX_HAND_SIZE:
		SignalBus._on_card_destroyed.emit(card)
	else:
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
