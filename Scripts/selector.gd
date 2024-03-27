extends Area2D

var curr_area
var other_areas
var dragging
var selector = true
var any_area
var any_other_area

var cursor = load("res://Sprites/Custom_Cursor.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(cursor)
	self.area_entered.connect(_area_entered)
	self.area_exited.connect(_area_exited)
	SignalBus._on_card_casted.connect(_on_card_casted)
	dragging = false
	other_areas = {}
	any_other_area = {}
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mousepos = get_viewport().get_mouse_position()
	self.position = Vector2(mousepos.x, mousepos.y)
	if dragging and curr_area:
		self.curr_area.position = self.position

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and !any_area:
			SignalBus._on_card_deselected.emit()
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and !UiVariables.mouse_busy and curr_area and 'draggable' in curr_area and curr_area.draggable:
			UiVariables.mouse_busy = true
			dragging = true
			curr_area.action = 'dragging'
			curr_area.location = 'none'
		elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and dragging:
			UiVariables.mouse_busy = false
			dragging = false
			if curr_area and 'action' in curr_area and curr_area.action == 'dragging':
				curr_area.action = 'none'

func _area_entered(area):
	any_area = area
	if area not in any_other_area:
		any_other_area[area] = true
	if curr_area == null and 'draggable' in area and area.draggable:
		curr_area = area
	elif 'draggable' in area and area.draggable:
		other_areas[area] = true

func _area_exited(area):
	if area in any_other_area:
		any_other_area.erase(area)
	if area == any_area:
		if any_area in any_other_area:
			any_other_area.erase(any_area)
		if any_other_area.size() > 0:
			var key = any_other_area.keys()[0]
			any_area = key
			any_other_area.erase(key)
		else:
			any_area = null

	if area in other_areas:
		other_areas.erase(area)
	if area == curr_area:
		if curr_area in other_areas:
			other_areas.erase(curr_area)
		if other_areas.size() > 0:
			var key = other_areas.keys()[0]
			curr_area = key
			other_areas.erase(key)
		else:
			curr_area = null

func _on_card_casted(area):
	if area == curr_area:
		curr_area.draggable = false
		curr_area = null

	
