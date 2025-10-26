extends Control

var cards = ['Wolf', 'Witch', 'Wolf', 'Bolt', 'Wolf']
var card_view_scene = preload("res://Cards/CardViewer.tscn")
var deck = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for card in cards:
		var card_obj = card_view_scene.instantiate()
		card_obj.card_id = card
		if deck:
			card_obj.deck = true
			$Label.text = 'Deck'
		$ScrollContainer/HBoxContainer.add_child(card_obj)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
