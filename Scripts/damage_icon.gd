extends Node2D

var damage
# Called when the node enters the scene tree for the first time.
func _ready():
	self.z_index += 25
	$Damage.text = "-" + str(self.damage)
	await get_tree().create_timer(1).timeout 
	self.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
