extends Button


var menu = true
# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(self._button_pressed)


func _button_pressed():
	get_tree().paused = false
	get_parent().queue_free()
