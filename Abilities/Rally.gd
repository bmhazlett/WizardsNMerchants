extends Node

var unit_card = preload("res://Cards/UnitCard.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func execute(parameters):
	print("RALLY", parameters)
	var amount = parameters[0]
	var key = "Soldier"
	var instance
	if CardDB.CARD_DB[key]['Type'] == 'Unit':
		instance = unit_card.instantiate()
	instance.card_id  = key

	get_parent().add_child(instance)
	instance._summon_token()
	_free()

func _free():
	await get_tree().create_timer(1).timeout 
	self.queue_free()
