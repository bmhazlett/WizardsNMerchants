extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_on_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_button_pressed():
	SignalBus._pause.emit()
	UiVariables.player_gold = 0
	UiVariables.player_arcane = 0
	UiVariables.player_gold_opponent = 0
	UiVariables.player_arcane_opponent = 0
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
