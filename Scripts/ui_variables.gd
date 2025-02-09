extends Node

var player_gold = 0
var player_arcane = 0

var player_gold_opponent = 0
var player_arcane_opponent = 0
var mouse_busy = false
var select = null
var target = null

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus._on_card_selected.connect(_on_card_selected)
	SignalBus._on_card_targeted.connect(_on_card_targeted)
	SignalBus._on_card_deselected.connect(_on_card_deselected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_card_selected(card):
	select = card
	print('select', select)
	
func _on_card_targeted(card):
	target = card
	print('target', target)
	
func _on_card_deselected():
	select = null
	target = null
	print('Deselected')
