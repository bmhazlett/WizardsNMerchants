extends Button

var complete_theme = load("res://Themes/complete_theme.tres")
# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_on_button_pressed)
	print(GameVariables.opp_one_win, " ", GameVariables.opp_two_win, " ", GameVariables.opp_three_win)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if "1" in self.name and GameVariables.opp_one_win:
		self.theme = complete_theme
	elif "2" in self.name and GameVariables.opp_two_win:
		self.theme = complete_theme
	elif "3" in self.name and GameVariables.opp_three_win:
		self.theme = complete_theme
	
func _on_button_pressed():
	if "1" in self.name:
		GameVariables.opponent = "1"
	elif "2" in self.name:
		GameVariables.opponent = "2"
	elif "3" in self.name:
		GameVariables.opponent = "3"
	StaticEffects._set_default()
	TransitionScreen.transition()
	await SignalBus._on_transition_finshed
	get_tree().change_scene_to_file("res://Scenes/duel_arena.tscn")
