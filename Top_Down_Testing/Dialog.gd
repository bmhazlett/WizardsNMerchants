extends RichTextLabel


var dialog_started = false
# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus._on_dialog_start.connect(_on_dialog_start)



func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_Z and event.pressed:
			if dialog_started:
				await get_tree().create_timer(.1).timeout # Wait for 2 seconds
				SignalBus._on_dialog_end.emit()
				self.text = ""
				dialog_started = false

func _on_dialog_start(dialog):
	print("start")
	dialog_started = true
	self.text = dialog
	

