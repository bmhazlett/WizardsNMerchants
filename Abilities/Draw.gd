extends Node

var unit_card = preload("res://Cards/UnitCard.tscn")
var spell_card = preload("res://Cards/SpellCard.tscn")
var turn

func _ready():
	SignalBus._on_card_draw.connect(_on_card_draw)

func execute(parameters):
	var game_manager = get_parent().get_node('GameManager')
	var cards_to_draw = parameters[0]
	turn = game_manager.turn
	var i = 0
	while i < cards_to_draw:
		SignalBus._draw_card.emit(turn, self)
		i += 1
		
func _on_card_draw(s_turn, deck, source):
	if source != self:
		return
	if len(deck.cards_in_deck) == 0:
		if s_turn == 'Opponent':
			SignalBus._on_game_end.emit('player')
		else:
			SignalBus._on_game_end.emit('opponent')
		return
	var key = deck.cards_in_deck.pop_front()

	var instance
	if CardDB.CARD_DB[key]['Type'] == 'Unit':
		instance = unit_card.instantiate()
	else:
		instance = spell_card.instantiate()
	instance.card_id  = key
	if s_turn == 'Opponent':
		instance.opponent = true
		instance.position = get_parent().get_node("Player_Card_Opponent").position
	else:
		instance.position = get_parent().get_node("Player_Card").position

	get_parent().add_child(instance)
		
func _free():
	await get_tree().create_timer(1).timeout 
	self.queue_free()
	
