extends Label

var curr_page = 0
var curr_page_min = 0
var curr_page_max = 10

var collection = []
var grid_width = 4
var grid_height = 3
var grid_area = grid_width * grid_height
var collection_card = preload("res://Cards/CollectionCard.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus._on_collection_page_backward.connect(_on_collection_page_backward)
	SignalBus._on_collection_page_forward.connect(_on_collection_page_forward)
	collection = Collection.collection

	curr_page_max = int(len(collection) / (grid_area))
	if len(collection) % (grid_area) == 0:
		curr_page_max -= 1
	_update_view()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.text = "Current\nPage: " + str(curr_page)

func _on_collection_page_backward():
	if curr_page > curr_page_min:
		curr_page -= 1
		_update_view()

func _on_collection_page_forward():
	if curr_page < curr_page_max:
		curr_page += 1
		_update_view()
	
func _update_view():
	for child in self.get_children():
		child.queue_free()
	
	var start = curr_page * grid_width * grid_height
	var end = start + grid_area
	var row = 0
	while start < end:
		if start >= len(collection.keys()):
			break
		var instance = collection_card.instantiate()
		instance.card_id = collection.keys()[start]
		add_child(instance)
		instance.position = Vector2(self.position.x + 100 + (86 * (start % grid_width)), self.position.y + 24 + (row * 100))
		start += 1
		if start % grid_width == 0:
			row += 1

