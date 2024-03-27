extends Label

var opponent = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if 'Opponent' in self.name:
		opponent = true
	if opponent:
		set_text('Arcane: ' + str(UiVariables.player_arcane_opponent))
	else:
		set_text('Arcane: ' + str(UiVariables.player_arcane))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if opponent:
		set_text('Arcane: ' + str(UiVariables.player_arcane_opponent))
	else:
		set_text('Arcane: ' + str(UiVariables.player_arcane))
