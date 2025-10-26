extends Node

# [owner, type]
var TARGET_ENCODING = ["all", "all"]
var damage_icon = preload("res://Scenes/damage_icon.tscn")

func _ready():
	pass

# Arguments is [damage, source, target]
func execute(arguements):
	print("DAMAGE: ", arguements)
	if len(arguements) < 3:
		return 
	var damage = arguements[0]
	var source = arguements[1]
	var target = arguements[2]

	damage = int(damage)
	target.damage += damage
	if damage > 0:
		print("INSTANCE", target, damage)
		await get_tree().create_timer(.1).timeout 
		var icon_instance = damage_icon.instantiate()
		icon_instance.position = target.position
		icon_instance.damage = damage
		add_child(icon_instance)
	if is_instance_valid(source) and source.type == "Spell":
		source._free()
	SignalBus._after_damage_dealt.emit(damage, source, target)

func is_legal_target(source, target):
	return true

func _free():
	await get_tree().create_timer(1).timeout 
	self.queue_free()
	
