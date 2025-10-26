extends Node

# [owner, type]
var TARGET_ENCODING = ['all', 'unit']

func _ready():
	pass

# Arguments is [action, [source.damage, target,damage], source, target]
func execute(arguements):
	print("Buff: ", arguements)
	if len(arguements) < 3:
		return
	var action_inputs = arguements[0]
	var source = arguements[1]
	var target = arguements[2]
	var atk_buff = action_inputs[0]
	var def_buff = action_inputs[1]
	target.base_attack += atk_buff
	target.base_hp += def_buff
	if is_instance_valid(source) and source.type == "Spell":
		source._free()

func is_legal_target(source, target):
	return true

func _free():
	await get_tree().create_timer(1).timeout 
	self.queue_free()
	
