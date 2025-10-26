extends Button


var menu = true
# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(self._button_pressed)


func _button_pressed():
	UiVariables.mouse_busy = false
	SignalBus._on_chose_ability.emit(get_parent().card)
	get_parent().card.menu_up = false
	get_parent().queue_free()
