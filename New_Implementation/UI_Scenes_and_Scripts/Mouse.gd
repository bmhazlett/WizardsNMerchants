extends Area2D

var dragging = false
var curr_area = null
# Called when the node enters the scene tree for the first time.
func _ready():
	self.area_entered.connect(_area_entered)
	self.area_exited.connect(_area_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.dragging:
		$Sprite2D.visible = false
	else:
		$Sprite2D.visible = true
	var mousepos = get_viewport().get_mouse_position()
	self.position = Vector2(mousepos.x, mousepos.y)
	if self.dragging and self.curr_area:
		self.curr_area.position = self.position
		
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		print(self.curr_area, self.dragging)
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and self.curr_area:
			print("CLICK")
			self.dragging = true
		elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and self.dragging:
			print("UNCLICK")
			self.dragging = false

func _area_entered(area):
	print('in')
	self.curr_area = area
	
func _area_exited(area):
	if area == self.curr_area:
		print('out')
		self.curr_area = null
	
