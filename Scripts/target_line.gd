extends Line2D

var start_point = null
var end_point = null
var lock = false

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus._on_card_deselected.connect(_on_card_deselected)
	SignalBus._on_card_selected.connect(_on_card_selected)
	SignalBus._on_card_successfully_targeted.connect(_on_card_successfully_targeted)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var game_manager = get_parent().get_parent().get_node('GameManager')
	if game_manager.turn == 'Opponent':
		return
	if !start_point or lock:
		return
	var mousepos = get_viewport().get_mouse_position()
	clear_points()
	add_point(start_point)
	add_point(Vector2(mousepos.x, mousepos.y))
	
func _on_card_deselected(card):
	self.queue_free()

func _on_card_selected(card, action, action_input):
	if lock:
		return
	start_point = card.position

func _on_card_successfully_targeted(source, target):
	if lock:
		return
	end_point = target.position
	clear_points()
	add_point(start_point)
	add_point(end_point)
	lock = true
