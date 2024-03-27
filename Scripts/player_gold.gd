extends Label

var opponent = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if 'Opponent' in self.name:
		opponent = true
	if opponent:
		set_text('Gold: ' + str(UiVariables.player_gold_opponent))
	else:
		set_text('Gold: ' + str(UiVariables.player_gold))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if opponent:
		set_text('Gold: ' + str(UiVariables.player_gold_opponent))
	else:
		set_text('Gold: ' + str(UiVariables.player_gold))
