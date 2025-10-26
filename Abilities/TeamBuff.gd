extends Node

func _ready():
	pass

func execute(arguements):
	print("TeamBuff: ", arguements)
	arguements = arguements[0]
	if len(arguements) < 3:
		return 
	var opponent = arguements[2].opponent
	print(arguements[2], opponent)
	if !opponent:
		StaticEffects.player_unit_atk_mod += arguements[0]
		StaticEffects.player_unit_hp_mod += arguements[1]
		print("Player Team Buffed")
	else:
		StaticEffects.opponent_unit_atk_mod += arguements[0]
		StaticEffects.opponent_unit_hp_mod += arguements[1]
		print("Opponent Team Buffed")
	print(StaticEffects.player_unit_atk_mod, StaticEffects.player_unit_hp_mod)


func end_execute(arguements):
	print("TeamBuff End: ", arguements)
	arguements = arguements[0]
	if len(arguements) < 3:
		return 
	var opponent = arguements[2].opponent
	
	print(arguements[2], opponent)

	if !opponent:
		StaticEffects.player_unit_atk_mod += arguements[0] * -1
		StaticEffects.player_unit_hp_mod += arguements[1] * -1
		print("Player Team Buff Ended")
	else:
		StaticEffects.opponent_unit_atk_mod += arguements[0] * -1
		StaticEffects.opponent_unit_hp_mod += arguements[1] * -1
		print("Opponent Team Buff Ended")

func _free():
	await get_tree().create_timer(1).timeout 
	self.queue_free()
	
