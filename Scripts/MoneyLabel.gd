extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	self.text = str(GameVariables.player_money) + ' money'
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	self.text = str(GameVariables.player_money) + ' money'
	pass
