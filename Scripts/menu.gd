extends Control

var paused = false
# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus._pause.connect(_pause)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		SignalBus._pause.emit()

func _pause():
	self.visible = not self.visible
	if not paused:
		get_tree().paused = true
		paused = true
	else:
		get_tree().paused = false
		paused = false
