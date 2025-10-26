extends Node2D
var collection_card = preload("res://Cards/CollectionCard.tscn")
var collection_display = []
var start = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not start:
		var instance
		for key in Collection.collection:
			print('Collection', key)
			instance = collection_card.instantiate()
			instance.card_id = key
			get_parent().add_child(instance)
			collection_display.append(instance)
		start = true

	var i = 0
	var split = 5
	var col = 0
	while i < len(collection_display):
		collection_display[i].position = Vector2(self.position.x + (125 * col), self.position.y + (i % split * 205))
		i += 1
		if i % split == 0:
			col += 1
