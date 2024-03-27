extends Area2D

var card = preload("res://Scenes/card.tscn")
var opponent = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if 'Opponent' in self.name:
		opponent = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input_event(viewport, event, shape_idx):
	return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			var instance = card.instantiate()
			var size = CardDB.CARD_DB.size()
			var random_key = CardDB.CARD_DB.keys()[randi() % size]
			instance.card_id  = random_key
			if opponent:
				instance.opponent = true
			get_parent().add_child(instance)
