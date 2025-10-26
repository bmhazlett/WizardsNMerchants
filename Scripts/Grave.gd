extends Node2D

@export var grave_list = []
@export var opponent: bool
var horizontal_card_viewer_scene = preload("res://Scenes/horizonal_card_viewer.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus._on_send_to_grave.connect(_on_send_to_grave)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_send_to_grave(card_id, opp):
	print(self.name, " GRAVE ", card_id, opp, " ", self.opponent)
	if opp == self.opponent:
		print(self.name, " HIT")
		grave_list.append(card_id)


func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			print("GRAVE: ", grave_list)
			var horizontal_card_viewer = horizontal_card_viewer_scene.instantiate()
			horizontal_card_viewer.cards = grave_list
			horizontal_card_viewer.position.x = 100
			horizontal_card_viewer.position.y = 100
			get_parent().add_child(horizontal_card_viewer)
			get_tree().paused = true
