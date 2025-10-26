extends Area2D

var curr_area
var other_areas
var dragging
var selector = true
var any_area
var any_other_area
var view
var cursor = load("res://Sprites/Custom_Cursor.png")
var unit_card = preload("res://Cards/UnitCard.tscn")
var worker_card = preload("res://Cards/WorkerCard.tscn")
var off_screen = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	self.area_entered.connect(_area_entered)
	self.area_exited.connect(_area_exited)
	SignalBus._on_card_casted.connect(_on_card_casted)
	dragging = false
	other_areas = {}
	any_other_area = {}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mousepos = get_viewport().get_mouse_position()
	if mousepos.y > 360:
		if not self.off_screen:
			print('off_screen: ', self.off_screen)
			self.off_screen = true
			_stop_dragging()
			$CollisionShape2D.disabled = true
	else:
		if self.off_screen:
			self.off_screen = false
			$CollisionShape2D.disabled = false

	self.position = Vector2(mousepos.x, mousepos.y)
	if dragging and curr_area:
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_stop_dragging()
		else:
			self.curr_area.position = self.position

func _stop_dragging():
	dragging = false
	if curr_area and 'location' in curr_area and curr_area.location == 'dragged':
		curr_area.location = 'hand'
		curr_area.dragging = false
		curr_area.selected = false
	UiVariables.mouse_busy = false
	if curr_area:
		curr_area.z_index -= 10

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var free = true
		for area in any_other_area:
			if 'selectable' in area and area.selectable:
				free = false
		if event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed and free and not dragging and UiVariables.select and UiVariables.select.type != 'Spell':
			SignalBus._on_card_deselected.emit(UiVariables.select)
			UiVariables.mouse_busy = false
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and !UiVariables.mouse_busy and curr_area and 'draggable' in curr_area and curr_area.draggable and curr_area.selected:
			UiVariables.mouse_busy = true
			dragging = true
			curr_area.location = 'dragged'
			curr_area.z_index += 10
		elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and dragging:
			_stop_dragging()
		if (curr_area and 'menu' not in curr_area) or not curr_area:
			SignalBus._on_destroy_menu.emit()

func _area_entered(area):
	if area not in any_other_area:
		any_other_area[area] = true
	if curr_area == null and 'draggable' in area and area.draggable:
		curr_area = area
	elif 'draggable' in area and area.draggable:
		other_areas[area] = true
	if 'location' in area and area.location == 'play' and not view and area.type == 'Unit':
		view = unit_card.instantiate()
		view.card_id  = area.card_id
		view.position = Vector2(72, 192)
		view.scale *= 2
		view.location = 'view'
		view.art = area.art
		view.card_name = area.card_name
		view.ability = area.ability
		get_parent().add_child(view)
		view.attack_mod = area.attack_mod
		view.hp_mod = area.hp_mod
		view.base_hp = area.base_hp
		view.base_attack = area.base_attack

func _area_exited(area):
	if area in any_other_area:
		any_other_area.erase(area)
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
	if 'location' in area and area.location == 'play':
		SignalBus._on_card_destroyed.emit(view)
		view = null

func _on_card_casted(area):
	if area == curr_area:
		curr_area.draggable = false
		curr_area = null
